# -*- encoding : utf-8 -*-
class AdminsController < ApplicationController
  skip_before_filter :require_admin_in_system , :require_login, :only => [:new, :create]
  before_filter :require_no_admin, :only => [:new, :create]
  before_filter :require_admin, :except => [:new, :create]

  def index
  @total_users = User.count
  @total_bookmarks = Library.count

      respond_to do |format|
      format.html # index.html.erb
    end
end

  # GET /admins/new
  def new
    @user = User.new
  end

  # POST /admins
  def create
    @user = User.new(params[:user])
    @user.password_required = true
    @user.is_admin = true

    if @user.save
      flash[:notice] = 'The admin user was created successfully. You can now sign in.'
      redirect_to new_session_url
    else
      render :action => 'new'
    end
  end

  private

  def require_no_admin
    redirect_to new_session_url unless User.no_admin_yet?
  end
end
