# -*- encoding : utf-8 -*-
class AddTipoToFolders < ActiveRecord::Migration
  def self.up
    add_column :folders, :tipo, :string
    add_column :folders, :modificado, :string
  end

  def self.down
    remove_column :folders, :modificado
    remove_column :folders, :tipo
  end
end
