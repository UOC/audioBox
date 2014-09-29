# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base

  has_many :folders
  has_many :user_files
  has_many :coments
  has_many :libraries
  has_and_belongs_to_many :groups

#this is for folders which this user has shared
has_many :shared_folders, :dependent => :destroy

#this is for folders which the user has been shared by other users
has_many :being_shared_folders, :class_name => "SharedFolder", :foreign_key => "shared_user_id", :dependent => :destroy

#this is for getting Folders objects which the user has been shared by other users
has_many :shared_folders_by_others, :through => :being_shared_folders, :source => :folder

  attr_accessor :password_confirmation, :password_required, :dont_clear_reset_password_token
  #attr_accessible :name, :email, :password, :password_confirmation, :password_required

  validates_confirmation_of :password
  validates_length_of :password, :in => 6..20, :allow_blank => true
  validates_presence_of :password, :if => :password_required
#  validates_presence_of :name, :email
  #validates_uniqueness_of :name, :email
  #validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/
validates_presence_of :name, :campususer, :campuslogin
  validates_uniqueness_of :campususer

  before_save :clear_reset_password_token, :unless => :dont_clear_reset_password_token
  after_create :create_root_folder_and_admins_group
#after_create :check_and_assign_shared_ids_to_shared_folders


  ['create', 'read', 'update', 'delete'].each do |method|
    define_method "can_#{method}" do |folder|
        if id == folder.user_id
        return true
      elsif method == 'read'  then
      return has_share_access?(folder)
    end

      has_permission = false
      groups.each do |group|
        unless group.permissions.send("find_by_folder_id_and_can_#{method}", folder.id, true).blank?
          has_permission = true
          break
        end
      end
      has_permission
    end
  end

#to check if a user has acess to this specific folder
def has_share_access?(folder)
	#has share access if the folder is one of one of his own
	return true if self.folders.include?(folder)

	#has share access if the folder is one of the shared_folders_by_others
	return true if self.shared_folders_by_others.include?(folder)

	#for checking sub folders under one of the being_shared_folders
	return_value = false
	folder.ancestors.each do |ancestor_folder|
	  return_value = self.shared_folders_by_others.include?(ancestor_folder)
	  if return_value #if it's true
	    return true
	  end
	end

	return false
end

def safe_delete
    transaction do
      destroy
      if User.count.zero?
        raise "Can't delete last user"
      end
    end
  end


  def password
    @password
  end

  def password=(new_password)
    @password = new_password
    unless @password.blank?
      self.password_salt = SecureRandom.base64(32)
      self.hashed_password = Digest::SHA256.hexdigest(password_salt + password)
    end
  end

  def member_of_admins?
    !groups.find_by_name('Admins').blank?
  end

  def refresh_reset_password_token
    self.reset_password_token = SecureRandom.hex(16)
    self.reset_password_token_expires_at = 1.hour.from_now
    self.dont_clear_reset_password_token = true
    save(:validate => false)
  end

  def refresh_remember_token
    self.remember_token = SecureRandom.base64(32)
    save(:validate => false)
  end

  def forget_me
    self.remember_token = nil
    save(:validate => false)
  end

  def self.authenticate(name, password)
    user = find_by_campuslogin(name) or return nil
    hash = Digest::SHA256.hexdigest(user.password_salt + password)
    hash == user.hashed_password ? user : nil

  end

  def self.no_admin_yet?
    find_by_is_admin(true).blank?
  end

  def is_box?
  true
  end


  private

  def clear_reset_password_token
    self.reset_password_token = nil
    self.reset_password_token_expires_at = nil
    self.email = campuslogin if email.nil? || email.blank?
  end

  def create_root_folder_and_admins_group
    parent_folder = Folder.create(:name => 'Root folder', :user_id => id, :tipo => 'library')
    check_and_assign_shared_ids_to_shared_folders
    if is_admin
      groups << Group.create(:name => 'Admins')
      Group.create(:name => 'Usuarios')
    else
      groups << Group.find_by_name(:'Usuarios')
  end
  end


  #this is to make sure the new user ,of which the email addresses already used to share folders by others, to have access to those folders
def check_and_assign_shared_ids_to_shared_folders
	#First checking if the new user's email exists in any of ShareFolder records
	shared_folders_with_same_email = nil
	shared_folders_with_same_email = SharedFolder.find_all_by_shared_email(email) unless email.nil?
	shared_folders_with_same_email = SharedFolder.find_all_by_shared_email(campuslogin) if shared_folders_with_same_email.nil?
	logger.debug "buscando shared books: #{shared_folders_with_same_email.inspect}"

	if shared_folders_with_same_email
	  #loop and update the shared user id with this new user id
	  shared_folders_with_same_email.each do |shared_folder|
	    shared_folder.shared_user_id = id
	    shared_folder.save
	  end
	end
end


end
