# -*- encoding : utf-8 -*-
class Coment< ActiveRecord::Base
#this is for the owner(creator) of the assets
  belongs_to :user
#for the bookmark being shared
  belongs_to :user_file

  attr_accessible :user_id, :user_file_id, :comentario

end
