# -*- encoding : utf-8 -*-
class Folder < ActiveRecord::Base
include ActsAsTree
  acts_as_tree :order => 'orden asc, name asc'

  belongs_to :user
  has_many :user_files, :order => "orden asc, attachment_file_name asc", :dependent => :destroy
  has_many :shared_folders, :dependent => :destroy
  has_many :permissions, :dependent => :destroy
  has_many :libraries, :dependent => :destroy

  attr_accessible :name, :user_id, :tipo, :modificado, :description, :orden

  #validates_uniqueness_of :name, :scope => :parent_id, :user_id
  validates_presence_of :name

  before_save :check_for_parent
  after_create :create_permissions

  def readonly?
    return false if !is_root_init?
    true if is_root? && !new_record?
  end

def is_root_path(sname)
false
    true if is_root? || name == sname
  end

  def is_root?
    parent.nil?
  end

def is_root_init?
    modificado.nil?
  end

def is_this_folder_being_shared?(userID)
  return false if user_id == userID
  true
end

  def has_children?
    children.count > 0
  end

  def self.root(uid)
    find_by_name_and_parent_id_and_user_id('Root folder', nil, uid)
  end

def self.finder(f_id,u_id)
    find_by_id_and_user_id!(f_id, u_id)
  end

def self.yaSincronizado(nombre, padre)
    find_by_name_and_parent_id(nombre, padre)
  end

def forceUpdate(nombre)
modificado = nil
    self.update_attributes(nombre)
  end

#a method to check if a folder has been shared or not
def shared?
	!self.shared_folders.empty?
end

def nameConcatenado
return name if description.nil? || description.blank?
return description if tipo == 'book folder'
"#{name}.- #{description}"
end

  private

  def check_for_parent
    raise 'Folders must have a parent.' if parent.nil? && name != 'Root folder'
  end

  def create_permissions
    unless is_root?
      parent.permissions.each do |permission|
        Permission.create! do |p|
          p.group = permission.group
          p.folder = self
          p.can_create = permission.can_create
          p.can_read = permission.can_read
          p.can_update = permission.can_update
          p.can_delete = permission.can_delete
        end
      end
    end
  end
end
