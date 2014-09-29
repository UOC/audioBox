# -*- encoding : utf-8 -*-
#require 'iconv'
require 'logger'

class CampusTranslator
  attr_accessor :special_tags
  ACTIVAR_DICTIONARI = false
  def initialize(options = {})
    @languages = Hash.new
    @dictionary_path = options[:dictionary_path] || '/server/bin/'
    @dictionary_file_extension = options[:dictionary_file_extension] || '.lng'
    @special_tags = options[:special_tags] || {}
  end

  def self.translate(tag, lang, options = {})
    CampusTranslator.instance(options).translate(tag, lang)
  end

  def self.translate_text(text, lang, options = {})
    CampusTranslator.instance(options).translate_text(text, lang)
  end

  def self.invalidate(lang = nil)
    CampusTranslator.instance.invalidate(lang)
  end

  def self.languages(options = {})
    CampusTranslator.instance(options).languages
  end

  def translate(tag, lang)
    # have to remove starting and finishing $
    begin
    @special_tags.has_key?(tag[1..tag.size-2]) ? @special_tags[tag[1..tag.size-2]] : (dictionary(lang).has_key?(tag[1..tag.size-2]) ? dictionary(lang)[tag[1..tag.size-2]] : tag)
    rescue Exception => e
  Rails.logger.error "error traduciendo tag: #{tag}"
  tag
    end
  end

  def translate_text(text, lang)
    text.gsub(/\$(\w+)\$/){|tag| translate(tag, lang)}
  end

  def dictionary(lang)
  if ACTIVAR_DICTIONARI
    unless @languages.has_key?(lang)
      @languages[lang] = Hash.new
      begin
        # We want to convert from ISO-8859-1 to UTF-8
        c = Iconv.new('UTF-8', 'ISO-8859-1')

        File.open("#{@dictionary_path}#{lang}#{@dictionary_file_extension}", 'r') do |f1|
          while line = f1.gets
            line.chomp!
            if line.length > 0 && line[0..0] =~ /[A-Z]/
              formatted_line = line.split('=')
              @languages[lang][formatted_line[0]] = c.iconv(formatted_line[1])
            end
          end
        end
      rescue Exception => e
      end
    end
    end

    @languages[lang]
  end

  def invalidate(lang)
    if lang
      @languages.delete(lang)
    else
      @languages.clear
    end
  end

  def self.instance(options = {})
    @instance ||= CampusTranslator.new(options)
    @instance
  end
end
