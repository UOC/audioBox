# -*- encoding : utf-8 -*-
include LocaleHelper
require 'timed_cache'
require 'rexml/document'
#require 'dummy_dropbox'

class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :no_cache
  before_filter :require_admin_in_system
  before_filter :require_login
  before_filter :set_locale
  before_filter :is_alto_contraste?, :only => [:index, :show, :edit, :new]

  helper :all # include all helpers, all the time
  helper_method :current_user, :signed_in?, :signed_in_dropbox?, :is_val_extFile?


  protected

  def campus_authorize
    campus_session = campussession_from_cache
    login_from_session(campus_session)
  end

  def user_session
    @user_session ||= UserSession.new(session)
  end

  def getFullPath(folder, tipo= '', root_name = nil)
    sname  = tipo == DROPBOX_PREFIX ? 'dropbox' : 'Root folder'
    sname  = root_name  if !root_name.nil?
    mipath = "/"
    if !folder.is_root_path(sname)
      folder.ancestors.each do |f|
        #next if f.is_root_path(sname)
        mipath = "/" + f.name + mipath if !f.is_root_path(sname)
      end
      mipath << folder.name << "/"
    end
    log "full pat : #{mipath} sname: #{sname}"
    mipath
  end

  def current_user
    @current_user ||= User.find_by_id(user_session[:user_id])
  end

  def signed_in?
    !!current_user
  end

def signed_in_dropbox?
    false
  end


  def require_admin_in_system
    redirect_to new_admin_url if User.no_admin_yet?
  end

  def require_admin
    redirect_to libraries_url unless current_user.member_of_admins?
  end

  def require_login
  if params[:s] && params[:s] != user_session.campussession_id
      empty_session
    end
    if current_user.nil?
      unless cookies[:auth_token].blank?
        user = User.find_by_remember_token(cookies[:auth_token])
        user.refresh_remember_token
        user_session.fill_from_campus(user, cookies[:auth_token])
        cookies[:auth_token] = user.remember_token
      else
        campus_session = campus_authorize
        if campus_session
          #store_location
          activaDropbox(false)
        end
      end
    end
  end

  def require_existing_parent_folder
  begin
    @parent_folder = Folder.find(params[:folder_id])
    if @parent_folder.user_id != current_user.id then
    if !has_share_access?(@parent_folder )
    flash[:error] = t(:error_folder_permiso)
      redirect_to folder_url(Folder.root(current_user.id))
  end
  end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t(:error_folder_not_found)
    redirect_to folder_url(Folder.root(current_user.id))
  end
  end

  def require_create_permission
    unless current_user.can_create(@parent_folder)
      flash[:error] = t(:error_folder_permiso_create)
      if @parent_folder.user_id == current_user.id then
        redirect_to folder_url(@parent_folder.parent)
      else
        redirect_to folder_url(Folder.root(current_user.id))
      end
    end
  end

  ['read', 'update', 'delete'].each do |method|
    define_method "require_#{method}_permission" do
      unless current_user.send("can_#{method}", @folder) || @folder.is_root?
        flash[:error] = t(:error_folder_permiso_method, :method => method)
        if @folder.user_id == current_user.id then
          redirect_to folder_url(@folder.parent)
        else
          redirect_to folder_url(Folder.root(current_user.id))
        end
      end
    end
  end

  def empty_session
  log "limpiando session"
    delete_cache_language_elems
    TimedCache.delete(user_session.campussession_id)
    user_session[:user_id] = nil
    user_session[:campussession_id] = nil
    @user_session = nil
    @current_user = nil
    reset_session
  end

  def check_campus_session
    campus_session = nil
    if params[:s]
      if user_session.campussession_id
        log "check session params[:s] = #{params[:s]} user_session.campussession_id = #{user_session.campussession_id}"
        empty_session if params[:s] != user_session.campussession_id
      else
        log "user_session.campussession_id is null"
      end
      campus_session = check_campus_session_is_valid(params[:s])
    else
      log "params[:s] is null"
      if user_session.campussession_id
        log "user_session.campussession_id = #{user_session.campussession_id}"
        campus_session = check_campus_session_is_valid(user_session.campussession_id)
      else
        log "user_session.campussession_id is null"
      end
    end
    campus_session
  end

  def check_campus_session_is_valid(s)
    campus_session = nil
    begin
      campus_session = ExtendedSession.find(s)
      log "checking campussession #{campus_session.authenticated}"
      if campus_session.authenticated != true.to_s
        empty_session
        campus_session = nil
      end
    rescue Exception => e
      log "error: #{e.message} -session: #{ExtendedSession.inspect}", 4
      empty_session
      campus_session = nil
    end
    # return campus session
    campus_session
  end

  def login_from_session(campus_session)
    if campus_session
      log "campus_session #{user_session[:campussession_id]} is valid - check session params = #{campus_session.inspect}"
      unless user_session[:user_id]
        userId = campus_session.userId.split('.')[1]
        user = User.find_by_campususer(userId)

        unless user
          user = User.new(:campususer => userId,
          :name => REXML::Text::unnormalize(campus_session.xmlEscapedFullname),
          :campuslogin => campus_session.login)
          user.save!
        end
        if user.name != REXML::Text::unnormalize(campus_session.xmlEscapedFullname)
          user.name = REXML::Text::unnormalize(campus_session.xmlEscapedFullname)
          user.save!
        end

        user_session.fill_from_campus(user, campus_session)
        log "Setting session of user #{user_session[:user_id]} for campus session #{user_session[:campussession_id]}"
      end

      begin
        # session cache elements
        # current profile not fetched from extended session because it can be modified
        current_profile = get_current_profile
        user_session.profile = current_profile
        locale = current_locale
        user_session.set_locale(params[:update_profile] ? campus_to_locale(current_profile.langId) : locale )

        fetch_cache_language_elems

        user_session.expiration_date = campus_session.expirationDate if campus_session.expirationDate?
      rescue Exception => e
        log "#{e.message} - #{e.backtrace}\n", 4
        store_location
        respond_to do |format|
          format.html {redirect_to LOGOUT_URL}
          format.js do
            render :update do |page|
              page.redirect_to(LOGOUT_URL)
            end
          end
          format.basicHTML {redirect_to LOGOUT_URL}
        end
      end
    else
      log "campus_session is null"
      store_location
      respond_to do |format|
        format.html {redirect_to LOGOUT_URL}
        format.js do
          render :update do |page|
            page.redirect_to(LOGOUT_URL)
          end
        end
        format.basicHTML {redirect_to LOGOUT_URL}
      end
    end
    campus_session
  end

  def no_cache
    response.headers["Cache-Control"] = "no-cache,no-store,max-age=0,must-revalidate,no-transform"
    #response.headers["Expires"] = Time.now()
    expires_now
    response.headers["Pragma"] ="no-cache"
  end

  def set_locale
    locale = current_locale
    #log "user session locale: #{locale}"
    if locale.nil?
      default_locale = DEFAULT_LOCALE
      request_language = request.env['HTTP_ACCEPT_LANGUAGE']
      request_language = request_language.nil? ? nil : request_language[/[^,;]+/]
      locale = params[:locale] || request_language || default_locale
      #log "Setting locale to: #{locale}"
    end
    user_session.set_locale(locale)
    @idioma = user_session.language.blank? ? "es" : user_session.language
    set_i18n_locale(user_session.language)
    log "user session locale: current: #{current_locale} set to: #{user_session[:locale]}. Language: #{user_session.language}. Country:#{user_session.country}"
  end

  def get_current_profile
    p = Profile.find(:current, :params => {:agent_id => user_session.campussession_id})
    log "check current profile params = #{p.inspect}"
    p
  end

def get_current_classroom
return nil if user_session[:domain_id].nil?
    p = Classroom.find(user_session[:domain_id], :params => {:agent_id => user_session.campussession_id})
    log "check current classroomparams = #{p.inspect}"
    p
  end

  def delete_cache_language_elems
    Rails.cache.delete("Profiles_#{user_session.campussession_id}")
  end

  def fetch_cache_language_elems
    # profiles
    @profiles = Rails.cache.fetch("Profiles_#{user_session.campussession_id}") { Profile.find(:all, :params => {:agent_id => user_session.campussession_id}) }
  end


  def reset_cache_language_elems
    delete_cache_language_elems
    fetch_cache_language_elems
  end

  def activaDropbox(activar = true)
    store_location

    user = current_user
    unless user.nil?
      log "in activaDropbox attributes hash user: #{user.inspect}"

      redirect_to(user_session[:return_to] || libraries_url)
      user_session[:return_to] = nil
    else
      log_failed_sign_in_attempt(Time.now, params[:username], request.remote_ip)
      flash[:error] = t(:error_user_bad)
      redirect_to new_session_url
    end
  end

  def log (miMSG = "", nivel = 0, app = "audiobox")
    mensage = "[#{app}]: #{signed_in? ? current_user.id : "aun no autentificado"} - #{miMSG}"
    case nivel
    when 0
      logger.debug mensage if nivel >= LOG_NIVEL
    when 1
      logger.info mensage if nivel >= LOG_NIVEL
    when 2
      logger.warn mensage if nivel >= LOG_NIVEL
    when 3
      logger.error mensage if nivel  >= LOG_NIVEL
    when 4
      logger.fatal mensage if nivel  >= LOG_NIVEL
    else
      logger.info mensage
    end
  end

  private

def mp3ToZip(folder, tipo = "zip", breadcrumbs = [])
  if current_user.can_read(folder)
    folder.user_files.each do |file|
    	breadcrumbs.append(file) if tipo == 'zip' || is_val_extFile?(file.attachment_file_name, ['mp3','wab'] )
    end
  end
  folder.children.each do |f|
    breadcrumbs = mp3ToZip(f, tipo , breadcrumbs)
    end
    breadcrumbs
  end

def is_val_extFile?(fileName, extension_black_list = ['mp3','wab','ogg'])
ext = fileName.chomp.downcase.gsub(/.*\./o, '')
return true  if extension_black_list.detect { |item| ext =~ /\A#{item}\z/i }
	false
end

  def campussession_from_cache
    # check if there is another user entering
    if params[:s] && params[:s] != user_session.campussession_id
      empty_session
    end
    s = params[:s] || user_session.campussession_id
    TimedCache.read(s, SESSION_CACHE_INTERVAL) { |s| check_campus_session_is_valid(s) }
  end

  def basicHTML_request?
    # request.env["HTTP_USER_AGENT"] && (request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]  ||  request.env["HTTP_USER_AGENT"][/MSIE 4.0/] ||
    #     request.env["HTTP_USER_AGENT"][/MSIE 4.01/] ||  request.env["HTTP_USER_AGENT"][/MSIE 5.01/]  ||  request.env["HTTP_USER_AGENT"][/MSIE 5.5/] )
    request.env["HTTP_USER_AGENT"] && MOBILE_USER_AGENTS.any?{ |ua| request.env["HTTP_USER_AGENT"][ua] }
  end

  helper_method :basicHTML_request?

  def set_basicHTML_format
    request.format = :basicHTML if (request.format == :html or request.format == :basicHTML) && (basicHTML_request? || params[:basic] == true.to_s)
  end

  def get_up_items
user_session[:hp_up_items] = params["up_items"] if !params["up_items"].nil?
user_session[:hp_up_items] = 25 if user_session[:hp_up_items].nil?
user_session[:hp_up_items]
end

  def is_alto_contraste?
@alto_contraste = false
  @rem_true = current_user.is_clasic_dialog != true unless current_user.nil? # enable show sj dialogs
  if !user_session[:hp_theme].nil?
    @alto_contraste = user_session[:hp_theme]
  else
    @alto_contraste = current_user.is_alto_contraste? unless current_user.nil?
    # hp_theme=true
    @alto_contraste = (params["hp_theme"] == "true") unless params["hp_theme"].nil?
    user_session[:hp_theme] = @alto_contraste unless current_user.nil?
  end
    @alto_contraste
  end

  def store_location
    log "full pat request: #{request.fullpath} - #{user_session[:return_to]}"
    user_session[:return_to] = request.fullpath if user_session[:return_to].nil?
  end

  def clear_return_to
    user_session[:return_to] = nil
  end

  def set_i18n_locale(params_locale)
    if params_locale
      if I18n.available_locales.include?(params_locale.to_sym)
        I18n.locale = params_locale
      else
        flash.now[:notice] = "#{params_locale} translation not available"
        logger.error
        flash.now[:notice]
      end
    end
  end

#to check if a user has acess to this specific folder
def has_share_access?(folder)

	#has share access if the folder is one of the shared_folders_by_others
	return true if current_user.shared_folders_by_others.include?(folder)

	#for checking sub folders under one of the being_shared_folders
	return_value = false
	folder.ancestors.each do |ancestor_folder|
	  return_value = current_user.shared_folders_by_others.include?(ancestor_folder)
	  if return_value #if it's true
	    return true
	  end
	end
	log "Intento acceso seccion sin permiso #{folder.id}", 1
	return false
	end

  def current_locale
    #"lang"=>"es", "country"=>"ES"
    if params[:lang]
      language = params[:lang]
      country = params[:country] || DEFAULT_COUNTRY
      locale = "#{language }-#{country }"
    else
      locale = user_session[:locale]
    end
    locale
  end

end

