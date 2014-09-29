# -*- encoding : utf-8 -*-
class SharedFolder < ActiveRecord::Base
  #this is for the owner(creator) of the assets
  belongs_to :user

  #this is for the user to whom the owner has shared folders to
  belongs_to :shared_user, :class_name => "User", :foreign_key => "shared_user_id"

  #for the folder being shared
  belongs_to :folder

  attr_accessible :user_id, :shared_email, :shared_user_id,  :message,  :folder_id, :library_id

end
