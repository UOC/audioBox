# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag|
  "<span class='field_with_errors'>#{html_tag}</span>".html_safe
end


# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '3.1.3' unless defined? RAILS_GEM_VERSION


# include Globalize so we won’t have to type Globalize::Locale.set all the time.
# Instead, we can just type Locale.set.
#include Globalize
# Base language. Be careful! don't change
#Globalize::Locale.set_base_language('en-US')
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

AudioBox::Application.initialize!

