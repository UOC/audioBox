# -*- encoding : utf-8 -*-
class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :hashed_password
      t.string :password_salt
      t.boolean :is_admin
      t.boolean :is_clasic_upload
      t.boolean :is_clasic_dialog
      t.boolean :is_alto_contraste
      t.string :access_key
      t.string :remember_token
      t.string :reset_password_token
      t.datetime :reset_password_token_expires_at
      t.column :locale, :string
      t.integer :campususer
      t.string :campuslogin
      t.timestamps
    end

    add_index :users, :campususer, :unique => true
    add_index :users, :email,                :unique => true

  end

  def self.down
  remove_index :users, :column => :campususer
    drop_table :users
  end
end
