# -*- encoding : utf-8 -*-
#include LocaleHelper
class UserSession
  UNDERSCORE = "_".freeze

  def initialize (session)
    @session = session
  end

  def fill_from_campus(connected_user, campus_session, extended = false)
    @session[:user_id] = connected_user.id if connected_user
    @session[:campussession_id] = campus_session.id
    set_locale(campus_session.locale.sub(/_/, '-'))
@session[:current_profile_id] = nil
  end

  def [](name)
    @session[name]
  end

  def []=(name, value)
    @session[name] = value
  end

  def user
    return nil unless @session[:user_id]
    @user ||= User.find(@session[:user_id])
  end

  def set_locale(locale = DEFAULT_LOCALE, language = nil, country = nil)
  locale = DEFAULT_LOCALE if locale .nil?
    language = locale.split(/-/)[0] if language.nil?
    country = locale.split(/-/)[1] if country.nil?
    @session[:locale] = locale
    @session[:language] = language
    @session[:country] = country
  end

  def language
    @session[:language] ||= DEFAULT_LANG
  end

  def country
    @session[:country] ||= DEFAULT_COUNTRY
  end

  def campussession_id
    @session[:campussession_id]
  end

def campuslogin
    user.campuslogin
  end


  def campususer_id
    user.campususer
  end

def profile=(current_profile)
    @session[:current_profile_id] = current_profile.id
    @session[:current_profile_usertype_id] = current_profile.userTypeId
    @session[:current_profile_usertype] = current_profile.userType
    @session[:current_profile_usersubtype_id] = current_profile.userSubTypeId
    @session[:current_profile_usersubtype] = current_profile.userSubType
    @session[:current_profile_app_id] = current_profile.appId

  end

  def profile
    @session[:current_profile_id]
  end

  def app_id
    @session[:current_profile_app_id]
  end

  def usertype_id
    @session[:current_profile_usertype_id]
  end

  def usersubtype_id
    @session[:current_profile_usersubtype_id]
  end

  def usersubtype
    @session[:current_profile_usersubtype]
  end

  def utility
    @session[:current_utility]
  end

  def utility=(value)
    @session[:current_utility] = value
  end

  def admin_user?
    self.user ? self.user.admin : false
  end

  def locale
    self.user ? @session[:locale] : DEFAULT_LOCALE
  end

  def expiration_date?
    !@session[:expiration_date].nil?
  end

  def expiration_date
    @session[:expiration_date]
  end

  def expiration_date=(value)
    @session[:expiration_date] = Time.parse(value) unless value.blank?
  end

  def requested_uri
    @session[:requested_uri]
  end

  def requested_uri=(value)
    @session[:requested_uri]=value
  end

  def profile_key
    "#{app_id}#{UNDERSCORE}#{usertype_id}#{UNDERSCORE}#{usersubtype_id}#{UNDERSCORE}#{campus_menu_id ? campus_menu_id : ''}#{UNDERSCORE}#{locale}"
  end

  def container_preferences
    return {'APPID' => app_id, 'CAMPUS_ID' => campussession_id, 'USERTYPEID' => usertype_id, 'USERSUBTYPEID' => usersubtype_id, 'LANG' => language}
  end

  private

  def user=(value)
    @user = value
  end
end
