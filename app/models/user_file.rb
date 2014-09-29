# -*- encoding : utf-8 -*-
class UserFile < ActiveRecord::Base
include Rails.application.routes.url_helpers

  mount_uploader :attachment, UserUploader

attr_accessible :attachment_file_name, :attachment, :attachment_cache, :remove_attachment, :description, :orden

  belongs_to :folder
  belongs_to :user
  has_many :coments, :dependent => :destroy

  before_save :update_asset_attributes

    validates_uniqueness_of :attachment_file_name, :scope => 'folder_id', :message => 'exists already'
  validates_format_of :attachment_file_name, :with => /^[^\/\\\?\*:|"<>]+$/, :message => 'cannot contain any of these characters: < > : " / \ | ? *'

  	def self.yaSincronizado(nombre, padre)
    find_by_attachment_file_name_and_folder_id(nombre, padre)
  end

def nameConcatenado
return attachment_file_name if description.nil? || description.blank?
# "#{attachment_file_name}.- #{description}"
description
end

def self.filesGuardados(padre)
    find_by_folder_id(padre)
  end

  #one convenient method to pass jq_upload the necessary information
  def to_jq_upload
  {
    "id" => read_attribute(:id),
    "tipo" => read_attribute(:attachment_content_type ),
    "description" => read_attribute(:description).nil? ? "" : read_attribute(:description),
    "name" => read_attribute(:attachment_file_name),
    "size" => read_attribute(:attachment_file_size),
    "url" => read_attribute(:id).nil? ? "" : file_path(:id => id),
    "thumbnail_url" => getImagenFile,
    "delete_url" => read_attribute(:id).nil? ? "" : file_path(:id => id),
    "delete_type" => "DELETE"
   }
  end

    private

  def update_asset_attributes
    if attachment.present? && attachment_changed?
      self.attachment_content_type = attachment.file.content_type
      self.attachment_file_size = attachment.file.size
    end
  end

def getImagenFile
ext = getExtFile
      list =MI_FILE_ESTENSIONS[ext]
                        return "http://#{AJAX_URL}/assets/icons/unknow.png" if list.nil?
                        "http://#{AJAX_URL}/assets/icons/#{list}"
end

def getExtFile
ext = attachment_file_name.chomp.downcase.gsub(/.*\./o, '')
ext
end

  end