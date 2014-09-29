# -*- encoding : utf-8 -*-
module LocaleHelper
  
  def campus_to_locale(lang)
    LANGUAGES[lang] ? LANGUAGES[lang] : DEFAULT_LANG
  end
  
  def locale_to_campus(locale)
    CAMPUSLANGUAGES[locale] ? CAMPUSLANGUAGES[locale] : DEFAULT_CAMPUS_LANG    
  end  
  
  def locale_to_portal(locale)
    'en' == locale ? 'eng' : ('es' == locale ? 'esp' : 'cat')
  end
end
