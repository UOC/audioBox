# -*- encoding : utf-8 -*-
class SessionsController < ApplicationController

  skip_before_filter :require_login
  layout "audiobox"

  # GET /sessions/new
  def new
  end

  # POST /sessions
  def create

    user = User.authenticate(params[:username], params[:password])

    unless user.nil?
      if params[:remember_me] == 'true'
        user.refresh_remember_token
        cookies[:auth_token] = { :value => user.remember_token, :expires => 2.weeks.from_now }
      end

      user_session[:user_id] = user.id
      user_session[:return_to]  = libraries_url


      #redirect_to(session[:return_to] || folders_url)
      #session[:return_to] = nil

    else
      log_failed_sign_in_attempt(Time.now, params[:username], request.remote_ip)
      flash[:error] = 'Username and/or password were incorrect. Try again.'
      redirect_to new_session_url
    end
  end


  def destroy
  if !current_user.nil?
  log "avandonando herramienta"
    current_user.forget_me
    cookies.delete :auth_token
  end
    empty_session

    respond_to do |format|
        format.html { redirect_to LOGOUT_URL }
        format.js
      end
  end

  def login
    @callBack = user_session[:return_to] || START_PAGE
    	@alto_contraste = is_alto_contraste?
    	@title = "login"
    empty_session
    if request.post?
      begin
        campus_session = Session.new(:name => params[:name], :password => params[:password])
        campus_session.save

        if campus_session.authenticated == true.to_s
          login_from_session(campus_session)
          @callBack = params[:callback] if  !params[:callback].nil?
          redirect_to(@callBack)
        else
          flash[:notice] = "Invalid user/password combination"
        end
      rescue Exception => e
        logger.info "Error in REST-OKI call: #{e.message}"
        flash[:notice] = "Could not process your request. Try again later"
      end
    end
  end

  def logout
    campus_session = user_session.campussession_id
    empty_session
    if campus_session
      redirect_to "http://#{HOST}/cgi-bin/uocapp/byebye?s=#{campus_session}&ACCIO=B_SURT&alert=false"
    else
      redirect_to LOGOUT_URL
    end
  end


  private

def log_failed_sign_in_attempt(date, username, ip)
    Rails.logger.error(
      "\nFAILED SIGN IN ATTEMPT:\n" +
      "=======================\n" +
      " Date: #{date}\n" +
      " Username: #{username}\n" +
      " IP address: #{ip}\n\n"
    )
  end
end





