# -*- encoding : utf-8 -*-
I18n.load_path += Dir[ File.join(Rails.root.to_s, 'config', 'locales', '*', '*.{rb,yml}') ]
I18n.default_locale = :ca
# Relationship between campus and Locale in languages
LANGUAGES = {
  'a' => 'ca-ES',
  'b' => 'es-ES',
  'c' => 'en-US'
}

# default language
DEFAULT_LANG = 'ca'
DEFAULT_COUNTRY = 'ES'
DEFAULT_LOCALE = "#{DEFAULT_LANG}-#{DEFAULT_COUNTRY}"

CAMPUSLANGUAGES = {'en' => 'c',
                 'es' => 'b',
                 'ca' => 'a'}

DEFAULT_CAMPUS_LANG = 'a'

PORTALLANGUAGES = {
  'en' => 'english',
  'es' => 'castellano',
  'ca' => 'catala'
}
