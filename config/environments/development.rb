# -*- encoding : utf-8 -*-
AudioBox::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

#PATH_PREFIX = '/rb/uocBox'
PATH_PREFIX = ''
PATH_UPLOAD_PREFIX = ''
PATH_SWF = '/assets/js'

# tipo de folder
DROPBOX_PREFIX = 'dropbox_folder'
UOCBOX_PREFIX = 'uoc_folder'
AS3BOX_PREFIX = 'as3_folder'

#tipo seccion
BOOK_PREFIX = "book folder"
SECTION_PREFIX = "capitol"

LOG_NIVEL = 0


# current host
HOST='cv.uoc.edu'
HOST_CV='cv.uoc.edu'
HOST_DV= "localhost:3000"

# Campus Gateway REST webapp main URL
CAMPUS_REST_WEBAPP="http://#{HOST_CV}/webapps/campusGateway"

# Location where logout action redirects
LOGOUT_URL="http://#{HOST_DV}#{PATH_PREFIX}/sessions/login"
AJAX_URL="#{HOST_DV}#{PATH_PREFIX}"
SIGNOUT_HOST = "http://#{HOST_DV}#{PATH_PREFIX}/signout"
START_PAGE= "http://#{HOST_DV}#{PATH_PREFIX}/folders"

TIPUS_MARCADOR = 0

# fequency (in seconds) of the session check
SESSION_CHECK_FREQUENCY=30

# Time (in seconds) until session logout to show logout alert
SESSION_TIMEOUT_ALERT_THRESHOLD=5*60

  # Mail settings
  # config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   :address => 'mailhost',
  #   :port => 587,
  #   :user_name => 'user_name',
  #   :password => 'password',
  #   :authentication => 'plain'
  # }

  # From address
  # ActionMailer::Base.default :from => 'Boxroom <yourname@yourdomain.com>'


  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
  MODO_DROPBOX = 0

end
