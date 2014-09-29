# -*- encoding : utf-8 -*-


class UserUploader < CarrierWave::Uploader::Base
#include CarrierWave::Compatibility::Paperclip
  # Include RMagick or ImageScience support:
  # include CarrierWave::RMagick
  # include CarrierWave::ImageScience
    #include CarrierWave::MiniMagick

attr_accessor :file_session, :file_tipo, :fullPath, :cnamed

  # Choose what kind of storage to use for this uploader:
   #storage :file
  #storage :fog
  #storage CarrierWave::Storage::Udrop

  def self.set_storage
  CarrierWave.clean_cached_files!
      #:fog
      :file
  end

   storage set_storage



  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{PATH_UPLOAD_PREFIX}uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  #def cache_dir
    "#{Rails.root}/tmp/uploads/#{Rails.env}/brands/logos"
  #end

  end
