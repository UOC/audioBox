# -*- encoding : utf-8 -*-
class CreateLibraries < ActiveRecord::Migration
  def change
    create_table :libraries do |t|
      t.string :name
      t.column :title, :string
      t.column :autor, :string
      t.column :site,  :string
      t.column :assignatura,  :string
      t.column :periodo,  :string
      t.column :security,  :string
      t.references :user
      t.references :folder
      t.timestamps
    end
    add_index :libraries, :user_id
    add_index :libraries, [:name, :title]
  end
end
