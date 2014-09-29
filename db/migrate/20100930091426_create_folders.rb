# -*- encoding : utf-8 -*-
class CreateFolders < ActiveRecord::Migration
  def self.up
    create_table :folders do |t|
      t.string :name
      t.string :description
      t.integer :orden
      t.references :user
      t.references :parent
      t.timestamps
    end
    add_index :folders, :parent_id
add_index :folders, :user_id

  end

  def self.down
    drop_table :folders
  end
end
