# -*- encoding : utf-8 -*-
AudioBox::Application.configure do
	# Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  config.log_level = :debug

  # Log file in other place than default
    #paths.log = "/var/log/mongrel/uocBox.#{Rails.env}.log"
    config.paths['log'] = "/var/log/mongrel/uocBox.#{Rails.env}.log"

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify


# tipo de folder
DROPBOX_PREFIX = 'dropbox_folder'
UOCBOX_PREFIX = 'uoc_folder'
AS3BOX_PREFIX = 'as3_folder'
LOG_NIVEL = 1

# current host
HOST='cv-pre.uoc.edu'
PATH_PREFIX = '/rb/audioBox'

# Campus Gateway REST webapp main URL
CAMPUS_REST_WEBAPP="http://#{HOST}/webapps/campusGateway"

# Location where logout action redirects
LOGOUT_URL="http://#{HOST}#{PATH_PREFIX}/sessions/login"
AJAX_URL="#{HOST}#{PATH_PREFIX}"

# fequency (in seconds) of the session check
SESSION_CHECK_FREQUENCY=30

# Time (in seconds) until session logout to show logout alert
SESSION_TIMEOUT_ALERT_THRESHOLD=5*60
MODO_DROPBOX = 1



end
