# -*- encoding : utf-8 -*-
class ComentsController < ApplicationController

before_filter :require_existing_coment, :only => [:show, :edit, :update, :destroy]
before_filter :require_existing_file, :only => [:new, :create, :index]

layout "audiobox"

  def index
  items_mostrar = get_up_items
  @all_coments = @file.coments.paginate(:page => params[:all_page], :per_page => items_mostrar ).order('user_file_id ASC')
  #@all_coments = current_user.coments.paginate(:page => params[:all_page], :per_page => items_mostrar ).order('user_file_id ASC')
  @title = t "library_view.llibreria"
  @breadcrumbs = "#{t('library_view.veure_comentaris')}: #{@file.nameConcatenado}"
  @mi_retorno = user_session[:layout_id] == 1 ? folders_path : folder_path(@folder.id)
  user_session[:layout_id_show] = file_coments_path(@file.id)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    if @coment
    @mi_retorno = user_session[:layout_id_show] if !user_session[:layout_id_show].nil?
  @title = t "library_view.show"
  @breadcrumbs = t("audiobox_view.comentari") unless @rem_true
  log "visualizando comentario: #{@coment.inspect}",1, "uocMark"
    respond_to do |format|
      format.html # show.html.erb
      #format.json { render :json => @library }
      format.js
    end
    end
  end

  def new
  @mi_retorno = user_session[:layout_id] == 1 ? folders_path : folder_path(@folder.id)
  @coment = Coment.new
    @title = t "library_view.new"
    @mi_action = 'create'
    @breadcrumbs = t("audiobox_view.new_coment") unless @rem_true

    respond_to do |format|
      format.html # new.html.erb
      #format.json { render :json => @library }
      format.js
    end
  end

def create
@mi_retorno = user_session[:layout_id] == 1 ? folders_path : folder_path(@folder.id)
@coment= Coment.new(params[:coment])
    @coment.user_id = current_user.id
    @coment.user_file_id = @file.id

    respond_to do |format|
      if @coment.save
        log "creado comentario: #{@coment.id}",1, "uocMark"
        format.html { redirect_to @mi_retorno, :notice => t(:msg_ok_created) }
        #format.json { render :json => @library, :status => :created, :location => @library }
      else
        format.html { render :action => "new" }
        #format.json { render :json => @library.errors, :status => :unprocessable_entity }
      end
  end
  end

def edit
@title = t "library_view.edit"
@mi_action = 'update'
@mi_retorno = user_session[:layout_id_show] if !user_session[:layout_id_show].nil?
@breadcrumbs = t("audiobox_view.rename_coment") unless @rem_true

respond_to do |format|
      format.html # edit.html.erb
      format.js
    end
  end

  def update
  if @coment
  @mi_retorno = user_session[:layout_id_show] if !user_session[:layout_id_show].nil?
  user_session[:layout_id_show] = nil
    respond_to do |format|
      if @coment.update_attributes(params[:coment])
        log "modificado comentario: #{@coment.id}",1, "uocMark"
        format.html { redirect_to @mi_retorno, :notice => t(:msg_ok_update) }
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
    if @coment
    log "eliminado comentario: #{@coment.id}",1, "uocMark"
    @mi_retorno = user_session[:layout_id_show] if !user_session[:layout_id_show].nil?
  user_session[:layout_id_show] = nil

    @coment.destroy

    tot_coment = @file.coments.size
    if (tot_coment  == 0)
      @mi_retorno = user_session[:layout_id] == 1 ? folders_path : folder_path(@folder.id)
    end

    respond_to do |format|
      format.html { redirect_to @mi_retorno  }
      #format.json { head :ok }
    end
  end
  end

  private

  def require_existing_coment
  begin
  	@mi_retorno = folders_path
  @coment = Coment.find(params[:id])
  @file = @coment.user_file
  @folder = @file.folder
    if @folder.user_id != current_user.id then
    if !has_share_access?(@folder)
    flash[:error] = t(:error_folder_permiso)
      redirect_to @mi_retorno
  end
  end
  @mi_retorno = user_session[:layout_id] == 1 ? folders_path : folder_path(@folder.id)
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t(:error_folder_not_found)
    log "Someone else deleted this library: #{params[:id]}. Your action was cancelled.", 4, "uocMark"
    redirect_to @mi_retorno
end
end

  def require_existing_file
  begin
    @file = UserFile.find(params[:file_id])
    @folder = @file.folder
    if @folder.user_id != current_user.id then
    if !has_share_access?(@folder)
    flash[:error] = t(:error_folder_permiso)
      redirect_to folder_url(Folder.root(current_user.id))
  end
  end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t(:error_folder_not_found)
    redirect_to folder_url(Folder.root(current_user.id))
  end
  end

end