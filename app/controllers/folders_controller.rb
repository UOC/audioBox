# -*- encoding : utf-8 -*-

class FoldersController < ApplicationController
  before_filter :require_existing_folder, :only => [:show, :edit, :update, :destroy]
  before_filter :require_existing_parent_folder, :only => [:new, :create]
  before_filter :require_folder_isnt_root_folder, :only => [:edit, :update, :destroy]

  before_filter :require_create_permission, :only => [:new, :create]
  before_filter :require_read_permission, :only => :show
  before_filter :require_update_permission, :only => [:edit, :update]
  before_filter :require_delete_permission, :only => :destroy

  layout "audiobox"

  # GET /folder
  def index
user_session[:domain_id] = params["domainid"] if !params["domainid"].nil?
      log "domain id: #{params["domainid"]}"
      # ejemplo "domainid=382785"
respond_to do |format|
  format.html  {redirect_to folder_url(Folder.root(current_user.id))}
  end
  end

  # GET /folders/:id
  # Note: @folder is set in require_existing_folder
  def show
    @is_this_folder_being_shared = true
    @breadcrumbs = 1
    user_session[:layout_id] = 2
    user_session[:layout_id_show] = nil
    @espai_ocupat = ""
    @title = t "library_view.listado"
    #current_folder = current_user.folders.find_by_id(params[:id])
    #@is_this_folder_being_shared = false if current_folder #just an instance variable to help hiding buttons on View

    @is_this_folder_being_shared = @folder.is_this_folder_being_shared?(current_user.id) #just an instance variable to help hiding buttons on View
    if !@folder.is_root?
      #if under a sub folder, we shouldn't see shared folders
      @being_shared_folders = []
    else
      #show folders shared by others
      @being_shared_folders = current_user.shared_folders_by_others(true)
    end
    @parent_tipo = @folder.tipo
    @permiso = true if @folder.tipo != "library"
      @espai_ocupat, @cuota = user_session[:espai_ocupat] ||= get_dropbox_account(DROPBOX_PREFIX)
      	if !@folder.is_root?
      	@libro = buscaRootBook(@folder)
      	@library = Library.find_by_folder_id(@libro.id)
        #else
        #@folder = Folder.find(params[:id]) #.includes(:libraries).where(	:user_id	=> current_user.id).order('is_preferido desc, name asc ' )
        #log "folder por preferido: #{@folder.inspect}"
      end
      	@folder_vacio = !@folder.has_children? && @folder.user_files.size == 0
      	@all_folder_vacio  = true
      	@mostrar_tabs = @folder.is_root?
      	@mostrarPlayer  = !@folder.is_root?
  @pestanya = (params[:book_page].nil?) ? 0 : 1

    respond_to do |format|
      format.html # show.html.erb
      #format.json { render :json => @folder}
    end
  end

  # GET /folders/:id/folders/new
  # Note: @parent_folder is set in require_existing_parent_folder
  def new
    if @current_user.is_box?
      @title = t "library_view.new"
      @folder = @parent_folder.children.build
      @b_folder =  @parent_folder
      @folder_list = @parent_folder
      breadcrumbs = calculaOrden(@parent_folder)
      @folder.name = calculSquema(@folder, "#{breadcrumbs}")
      @folder.orden = breadcrumbs
      @breadcrumbs = t("audiobox_view.new_folder") unless @rem_true
      respond_to do |format|
        format.html # new.html.erb
        #format.json { render :json => @folder }
        format.js
      end
    else
      redirect_to folder_url(Folder.root(current_user.id))
    end
  end

  # POST /folders/:id/folders
  # Note: @parent_folder is set in require_existing_parent_folder
  def create
    fetCorrecte = false
    if !params[:folder][:name].blank?
    movido = false

if !params["parent_id"].nil? && @parent_folder.id != params["parent_id"]
orden = calculaOrden(@parent_folder)
      name = calculSquema(@parent_folder, "#{@parent_folder.orden}.#{orden}")
    @parent_folder = Folder.find(params["parent_id"])
    movido = true
  end
      @folder = @parent_folder.children.build(params[:folder])
      @folder.user_id = current_user.id
      @folder.tipo = SECTION_PREFIX
          if movido == true
if orden  == @folder.orden && name == @folder.name
breadcrumbs = calculaOrden(@parent_folder)
      @folder.name = calculSquema(@folder, "#{breadcrumbs}")
      @folder.orden = breadcrumbs
      log "creando subseccion#{breadcrumbs} -- #{@folder.name}"
  end
  end
      if @folder.save
        fetCorrecte = true
      end
      end

    respond_to do |format|
      if fetCorrecte
        format.html { redirect_to folder_url(@parent_folder), :notice => t(:msg_ok_created) }
        #format.json { render :json => @parent_folder, :status => :created, :location => folder_url(@parent_folder)}
      else
      flash.now[:notice] = t(:msg_bad_save)
      @title = t "bookmark_view.new"
      @folder = @parent_folder.children.build
        format.html { render :action => "new" }
        #format.json { render :json => @folder.errors, :status => :unprocessable_entity }
        format.js { render :action => "new" }
      end
    end
  end

  # GET /folders/:id/edit
  # Note: @folder is set in require_existing_folder
  def edit
    @title = t "library_view.edit"
    @mi_action = 'edit'
    @folder_list = @folder
    @breadcrumbs = t("audiobox_view.rename_folder") unless @rem_true
    respond_to do |format|
      format.html # edit.html.erb
      format.js
    end
  end

  # PUT /folders/:id
  # Note: @folder is set in require_existing_folder
  def update
    if !params["parent_id"].nil? && @folder.parent_id != params["parent_id"]
    @parent_folder = Folder.find(params["parent_id"])
    @folder.parent_id = @parent_folder.id
    breadcrumbs = calculaOrden(@parent_folder)
      params[:folder][:name] = calculSquema(@folder, "#{breadcrumbs}") if params[:folder][:name] == @folder.name
      params[:folder][:orden] = breadcrumbs if params[:folder][:orden] == @folder.orden
      log "mobiendo seccion #{breadcrumbs} -- #{@folder.name}"
  end
    respond_to do |format|
      if @folder.update_attributes(params[:folder].merge({:user_id => current_user.id}))
        format.html { redirect_to folder_url(@folder.parent), :notice => t(:msg_ok_update) }
        #format.json { head :ok }
      else
      flash[:notice] = t(:msg_bad_save)
        format.html { render :action => "edit" }
        #format.json { render :json => @folder.errors, :status => :unprocessable_entity }
        format.js { render :action => "edit" }
      end
    end
  end

  # DELETE /folder/:id
  # Note: @folder is set in require_existing_folder
  def destroy
    parent_folder = @folder.parent
    if @folder.tipo == BOOK_PREFIX
    @library = Library.find_by_folder_id(@folder.id)
    @library.destroy
  end
      @folder.destroy


    respond_to do |format|
      format.html { redirect_to folder_url(parent_folder)}
      #format.json { head :ok }
    end
  end

  #this handles ajax request for inviting others to share folders
  def share
  end

  def update_multiple
    if !params["Elimina"].nil? && !params["folder"].nil?
    log "eliminando multiple folders ",1, "audioBox"
    params["folder"].each do |param|
      log "parametres folder: #{param[0]} - valor: #{param[1]}", 0, "audioBox"
      id = param[0]
      if !id.nil?
        valor = param[1]["is_preferido"] == '1'
        valor = true if params["checkbox_all"] ==  "1"
        @folder = Folder.find_by_id_and_user_id(id, current_user.id)
        if @folder && valor
          log "canviado estado folder: #{id} - #{@folder.name} - valor: #{valor}",1, "audioBox"
            @folder.destroy
        end
      end
    end
  end

    user_session[:my_params] = params

    respond_to do |format|
      format.html { redirect_to "http://#{AJAX_URL}/files/#{params[:id]}/update_multiple" }
    end
  end

  private

def buscaRootBook(folder)
book_folder = folder
folder.ancestors.each do |ancestor_folder|
	book_folder = ancestor_folder if ancestor_folder.tipo == BOOK_PREFIX
end
book_folder
end


  def require_existing_folder
    begin
    @folder = Folder.find(params[:id])
    if @folder.user_id != current_user.id then
    if !has_share_access?(@folder )
    flash[:error] = t(:error_folder_permiso)
      redirect_to folder_url(Folder.root(current_user.id))
  end
  end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t(:error_folder_not_found)
    redirect_to folder_url(Folder.root(current_user.id))
  end
  end

  def require_folder_isnt_root_folder
    if @folder.is_root?
      flash[:error] = t(:error_folder_root)
      redirect_to folder_url(Folder.root(current_user.id))
    end
  end

  # Overrides require_delete_permission in ApplicationController
  def require_delete_permission
    unless current_user.can_delete(@folder) || @folder.is_root?
      flash[:error] = t(:error_folder_permiso_delete)
      if @folder.user_id == current_user.id then
        redirect_to folder_url(@folder.parent)
      else
        redirect_to folder_url(Folder.root(current_user.id))
      end
    else
      require_delete_permissions_for(@folder.children)
    end
  end

  def require_delete_permissions_for(folders)
    folders.each do |folder|
      unless current_user.can_delete(folder)
        flash[:error] = t(:error_folder_permiso_delete_children)
        if folder.user_id == current_user.id then
          redirect_to folder_url(folder.parent)
        else
          redirect_to folder_url(Folder.root(current_user.id))
        end
      else
        # Recursive...
        require_delete_permissions_for(folder.children)
      end
    end
  end


def get_dropbox_account(tipo)
      cuota  =0
      resultado = ""
    return resultado, cuota
  end

def calculSquema(folder, breadcrumbs = '')
  if current_user.can_read(folder.parent) || folder.parent.is_root? then
  	if folder.parent.tipo == SECTION_PREFIX
    breadcrumbs = "#{folder.parent.orden}.#{breadcrumbs}"
  end
  end
    breadcrumbs = calculSquema(folder.parent, breadcrumbs) if folder.parent.tipo == SECTION_PREFIX
    breadcrumbs.html_safe
  end

def calculaOrden(folder)
contador = folder.children.count + 1
contador
end

end