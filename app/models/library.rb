# -*- encoding : utf-8 -*-
class Library < ActiveRecord::Base
#acts_as_taggable
belongs_to :user
belongs_to :folder


   #
   attr_accessible :name, :title, :site, :security, :is_preferido,:autor, :assignatura, :periodo

   #
   #  Make sure we have a link and a title.
   #
   validates_presence_of :title, :security

   #
   #  Make sure the link is well-formed
   #
   #validates_format_of :site,
                       #:with    => %r{^(http://|https://|ftp://|mailto://|news://)}i,
                       #:message => :inclusion_link

   #
   #  We only recognise two types of security
   #
   validates_format_of :security,
                       :with   => %r{^(public|private)$}i,
                       :message => :inclusion_seguryty

before_save :create_root_book

def self.preferits(uid, valor)
    find_by_user_id_and_is_preferido(uid, valor)
  end

def self.is_last_item(libraries_array, library_elem)
  libraries_array.last.id == library_elem.id
end

def create_root_book
unless folder_id
    parent_folder = Folder.root(user_id)
    contador = parent_folder.children.count + 1
    mfolder = parent_folder.children.build(:name => "book_#{contador}")
           mfolder.user_id = user_id
           mfolder.tipo = 'book folder'
                      mfolder.description = title
           mfolder.orden = self.is_preferido ? 1 : 0
           mfolder.save
                      self.folder_id =  mfolder.id
           else
           mfolder = Folder.find_by_id(folder_id)
           orden = self.is_preferido ? 1 : 0
           logger.debug "libro: #{mfolder.inspect}"
           mfolder.forceUpdate({:description => title, :orden => orden})
           end
end
end


