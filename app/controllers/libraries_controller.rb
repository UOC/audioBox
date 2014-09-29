# -*- encoding : utf-8 -*-
class LibrariesController < ApplicationController

before_filter :require_existing_library, :only => [:show, :edit, :update, :destroy]
before_filter :is_a_widget, :only => [:index, :show, :edit, :new]

layout "library"

  # GET /libraries
  # GET /libraries.json
  def index
  @user_modul_id  =   1
      user_session[:domain_id] = params["domainid"] if !params["domainid"].nil?
      log "domain id: #{params["domainid"]}"
      # ejemplo "382785"
      user_session[:layout_id] = 3
      user_session[:layout_id_show] = nil

  items_mostrar = get_up_items
    @contador_1 = ""
    @title = t "library_view.llibreria"
    @pestanya = (params[:all_page].nil?) ? 0 : 1
    @pestanya = 2 if !params[:public_page].nil?
    @libraries = current_user.libraries.where(:is_preferido => true).paginate(:page => params[:preferit_page], :per_page => items_mostrar ).order('name ASC, title ASC')
    @all_libraries = current_user.libraries.paginate(:page => params[:all_page], :per_page => items_mostrar ).order('name ASC, title ASC')
    @being_shared_folders = current_user.shared_folders_by_others.where("library_id is not null").paginate(:page => params[:public_page], :per_page => items_mostrar ).order('name ASC')
    @campusTranslator  = campusTranslator
    @mostrar_tabs = true
      	@mostrarPlayer  = false

    respond_to do |format|
      format.html # index.html.erb
      #format.json { render :json => @libraries }
    end
  end

  # GET /libraries/1
  # GET /libraries/1.json
  def show
  if @library
  @mi_retorno = user_session[:layout_id] == 1 ? libraries_path : folder_path(@library.folder_id)
  user_session[:layout_id_show] = library_path(@library.id)
  @title = t "library_view.show"
  @mostrar_tabs, @mostrarPlayer, @class_audio = false, true, " book_view"
  @breadcrumbs = "#{t('audiobox_view.llegeix_llibre')}"
  log "visualizando libro: #{@library.inspect}",1, "uocMark"
  @folder = Folder.find(@library.folder_id)
    if @folder.user_id != current_user.id then
    if !has_share_access?(@folder)
    flash[:error] = t(:error_folder_permiso)
      redirect_to folder_url(Folder.root(current_user.id)) and return
  end
  end
  @lista_player = mp3ToZip(@folder, "player")
    respond_to do |format|
      format.html # show.html.erb
      #format.json { render :json => @library }
    end
    end
  end

  # GET /libraries/new
  # GET /libraries/new.json
  def new
  @aula_llibre  = false
  @mi_action = 'create'
  current_classroom = get_current_classroom
    @library = Library.new
    @title = t "library_view.new"
    @library.autor = current_user.name
    if !current_classroom.nil?
    @library.site = current_classroom.attributes['codeTercers']
    @library.assignatura = current_classroom.attributes['title']
    @library.periodo = Time.now
    @aula_llibre  = true
  end
  @mi_retorno = user_session[:layout_id] == 1 ? libraries_path : folders_path

    respond_to do |format|
      format.html # new.html.erb
      #format.json { render :json => @library }
      format.js
    end
  end

  # GET /libraries/1/edit
  def edit
  @title = t "library_view.edit"
  @mi_retorno = user_session[:layout_id] == 1 ? libraries_path : folder_path(@library.folder_id)
  @mi_retorno = user_session[:layout_id_show] if !user_session[:layout_id_show].nil?
  user_session[:layout_id_show] = nil
  @mi_action = 'update'
    respond_to do |format|
      format.html # edit.html.erb
      format.js
    end
  end

  # POST /libraries
  # POST /libraries.json
  def create
    @library = Library.new(params[:library])
    @library.user_id = current_user.id

    respond_to do |format|
      if @library.save
        log "creado favorito: #{@library.id}",1, "uocMark"
        @mi_retorno = user_session[:layout_id] == 1 ? libraries_path : folder_path(@library.folder_id)
        format.html { redirect_to @mi_retorno, :notice => t("library_view.good_created") }
        #format.json { render :json => @library, :status => :created, :location => @library }
      else
        format.html { render :action => "new" }
        #format.json { render :json => @library.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /libraries/1
  # PUT /libraries/1.json
  def update
  if @library
    respond_to do |format|
      if @library.update_attributes(params[:library])
        log "modificado favorito: #{@library.id}",1, "uocMark"
        @mi_retorno = user_session[:layout_id] == 1 ? libraries_path : folder_path(@library.folder_id)
        format.html { redirect_to @mi_retorno, :notice => t("library_view.good_updated") }
        #format.json { head :ok }
      else
        format.html { render :action => "edit" }
        #format.json { render :json => @library.errors, :status => :unprocessable_entity }
      end
    end
    end
  end

  # DELETE /libraries/1
  # DELETE /libraries/1.json
  def destroy
    if @library
    log "eliminado favorito: #{@library.id}",1, "uocMark"
    @library.destroy
    @mi_retorno = user_session[:layout_id] == 1 ? libraries_path : folders_path

    respond_to do |format|
      format.html { redirect_to @mi_retorno }
      #format.json { head :ok }
    end
  end
  end

  def update_multiple
  log "modificando lista preferidos",1, "uocMark"
  params["library"].each do |param|
  	log "parametres faboritos: #{param[0]} - valor: #{param[1]}", 0, "uocMark"
  	id = param[0]
  	if !id.nil?
  	valor = param[1]["is_preferido"] == '1'
  	@library = Library.find_by_id_and_user_id(id, current_user.id)
  	  if @library && @library.is_preferido != valor
  	@library.update_attributes(:is_preferido => valor)
  	log "canviado estado favorito: #{id} - valor: #{valor}",1, "uocMark"
  end
  end
  end
  respond_to do |format|
      format.html { redirect_to libraries_url }
      #format.json { head :ok }
    end
end


private

  def require_existing_library
    begin
    	@mi_retorno = user_session[:layout_id] == 1 ? libraries_path : folders_path
    @library = Library.find(params[:id])
    if @library.user_id != current_user.id then
    @folder = Folder.find(@library.folder_id)
    if !has_share_access?(@folder)
    flash[:error] = 'The root folder cannot be deleted or renamed.'
      redirect_to @mi_retorno
  end
  end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Someone else deleted this library. Your action was cancelled.'
    log "Someone else deleted this library: #{params[:id]}. Your action was cancelled.", 4, "uocMark"
    redirect_to @mi_retorno
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
	return false
	end


  def is_a_widget
  @user_modul_id  = user_session[:hp_modul]
  if !params["libs"].nil?
libs = params['libs'].split('library')
if libs.size > 0
	@user_modul_id  = (libs[1].split('.'))[0].sub('/','')
	user_session[:hp_modul] = @user_modul_id
	end
	end
	user_session[:hp_modul]
end


def campusTranslator

      app = user_session.app_id
      lang = locale_to_campus(user_session.language)
      ses = user_session[:campussession_id]
      userid = user_session.campususer_id
      userlogin = user_session.campuslogin
      tipeid = user_session.usertype_id
      subtypeid = user_session.usersubtype_id

      # init translator
      instance = CampusTranslator.instance
      instance.special_tags = {"APPID" => "#{app}",
                                                "LANGID" => "#{lang}",
                                                "SESSIONID" => "#{ses}",
                                                "USERTYPEID" => "#{tipeid}",
      "USERSUBTYPEID" => "#{subtypeid}",
      "USERID" => "#{userid}",
      "USERLOGIN" => "#{userlogin}"
                                                }

                                                instance
end

def get_up_items
user_session[:hp_up_items] = params["up_items"] if !params["up_items"].nil?
user_session[:hp_up_items] = 25 if user_session[:hp_up_items].nil?
user_session[:hp_up_items]
end

end

