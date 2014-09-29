# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  before_filter :require_admin, :except => [:edit, :update]
  before_filter :require_existing_user, :only => [:edit, :update, :destroy]
  before_filter :require_deleted_user_isnt_admin, :only => :destroy

layout "audiobox"

  # GET /users
  def index
    @all_users = User.paginate(:page => params[:all_page], :per_page => 100).order('name ASC')
    @paginacio_activa  = true
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users
  def create
    @user = User.new(params[:user].merge({ :password_required => true }))

    if @user.save
      set_groups
      redirect_to users_url
    else
      render :action => 'new'
    end
  end

  # GET /users/:id/edit
  # Note: @user is set in require_existing_user
  def edit
  @title = t("audiobox_view.pref_user")
  respond_to do |format|
      format.html # edit.html.erb
      format.js
    end
  end

  # PUT /users/:id
  # Note: @user is set in require_existing_user
  def update
    if @user.update_attributes(params[:user].merge({ :password_required => false }))
      set_groups
      user_session[:hp_theme] = @user.is_alto_contraste?
      flash[:notice] = t(:msg_ok_update)
      redirect_to folders_url
    else
    @title = t("audiobox_view.pref_user")
      render :action => 'edit'
    end
  end

  # DELETE /user/:id
  # Note: @user is set in require_existing_user
  def destroy
    @user.destroy
    redirect_to users_url
  end

  private

  def require_existing_user
    if current_user.member_of_admins? && params[:id] != current_user.id.to_s
      @title = t("audiobox_view.edit_user")
      @user = User.find(params[:id])
    else
      @title = t("audiobox_view.pref_user")
      @user = current_user
    end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Someone else deleted the user. Your action was cancelled.'
    redirect_to users_url
  end

  def require_deleted_user_isnt_admin
    if @user.is_admin
      flash[:error] = 'The admin user cannot be deleted.'
      redirect_to users_url
    end
  end

  def set_groups
    if current_user.member_of_admins?
      @user.group_ids = params[:user][:group_ids]
      @user.groups << Group.find_by_name('Admins') if @user.is_admin
    end
  end
end
