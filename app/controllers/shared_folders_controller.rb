# -*- encoding : utf-8 -*-
class SharedFoldersController < ApplicationController

  before_filter :require_existing_folder, :only => [:new, :create, :show]
  before_filter :require_existing_shared_folder, :only => [:edit, :update, :destroy]

layout "audiobox"

  def new
  #@folder = Folder.find(params[:id])
  @mi_retorno = user_session[:layout_id] == 1 ? folders_path : folder_path(@folder.parent_id)
  @title = t "library_view.new"
  @cabecera = @folder.tipo == 'book folder'  ? t("audiobox_view.inviteBook") : t("audiobox_view.invite")

    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end

def create
#first, we need to separate the emails with the comma
	email_addresses = params[:email_addresses].split(",")

	email_addresses.each do |email_address|
	  #save the details in the ShareFolder table
	  @shared_folder = current_user.shared_folders.new
	  @shared_folder.folder_id = params[:folder_id]
	  # en pestanya compartits sols mostra registres amb library  no nnil
	  library = Library.find_by_folder_id(params[:folder_id])
	  @shared_folder.library_id = library.id if !library.nil?
	  @shared_folder.shared_email = email_address

	  #getting the shared user id right the owner the email has already signed up with ShareBox
	  #if not, the field "shared_user_id" will be left nil for now.
	  shared_user = User.find_by_email(email_address)
	  shared_user = User.find_by_campuslogin(email_address.split("@")[0]) if shared_user.nil?
	  @shared_folder.shared_user_id = shared_user.id if shared_user



	  @shared_folder.message = params[:message]
	  @shared_folder.save

	  #now we need to send email to the Shared User
	  #now send email to the recipients
#UserMailer.invitation_to_share(@shared_folder).deliver
	end

  @mi_retorno = user_session[:layout_id] == 1 ? folders_path : folder_path(@folder.parent_id)
	redirect_to @mi_retorno

#	#since this action is mainly for ajax (javascript request), we'll respond with js file back (refer to share.js.erb)
#	respond_to do |format|
	  #format.js {
	  #}
	#end
end

  def edit
  log "shared folder #{@shared_folder.inspect	}"
  @folder = Folder.find(@shared_folder.folder_id)
  @title = t "library_view.edit"
  @mi_retorno = user_session[:layout_id_show] if !user_session[:layout_id_show].nil?
  @cabecera = @folder.tipo == 'book folder'  ? t("audiobox_view.inviteBook") : t("audiobox_view.invite")

respond_to do |format|
      format.html # edit.html.erb
      format.js
    end
  end

def update
@mi_retorno = user_session[:layout_id_show] if !user_session[:layout_id_show].nil?
user_session[:layout_id_show] = nil
shared_user = User.find_by_email(params[:shared_folder][:shared_email])
	 shared_user = User.find_by_campuslogin(params[:shared_folder][:shared_email].split("@")[0]) if shared_user.nil?
	params[:shared_folder][:shared_user_id] = shared_user.id if shared_user
    if @shared_folder.update_attributes(params[:shared_folder])
      flash[:notice] = t(:msg_ok_update)
      redirect_to @mi_retorno
    else
    @title = t "library_view.edit"
  @cabecera = @folder.tipo == 'book folder'  ? t("audiobox_view.inviteBook") : t("audiobox_view.invite")
      render :action => 'edit'
    end
  end


  def show
  #@shared_folders = SharedFolder.find_by_folder_id(params[:id])
  #@folder = Folder.find(params[:id])
  @shared_folders = @folder.shared_folders
  @shared_folders= [] if  @shared_folders.nil?
  @mi_retorno = user_session[:layout_id] == 1 ? folders_path : folder_path(@folder.id)
  user_session[:layout_id_show] = shared_folder_path(@folder.id)
  @breadcrumbs = @folder.tipo == 'book folder'  ? t('audiobox_view.llibre_compartit_amb') : t('audiobox_view.compartit_amb')
  end

def destroy
@shared_folder = SharedFolder.find(params[:id])
@mi_retorno = user_session[:layout_id_show] if !user_session[:layout_id_show].nil?
user_session[:layout_id_show] = nil
@shared_folder.destroy
redirect_to @mi_retorno
end

private

def require_existing_folder
begin
p = params["folder_id"] || params[:id]
    @folder = current_user.folders.find_by_id(p)
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t(:error_folder_not_found)
    redirect_to folder_url(Folder.root(current_user.id))
  end
  end

def require_existing_shared_folder
begin
    @shared_folder = SharedFolder.find(params[:id])
    @mi_retorno = folders_path
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t(:error_folder_not_found)
    redirect_to folder_url(Folder.root(current_user.id))
  end
  end

end
