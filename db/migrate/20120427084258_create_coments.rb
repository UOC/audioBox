class CreateComents < ActiveRecord::Migration
  def change
    create_table :coments do |t|
      t.integer :user_id
      t.integer :user_file_id
      t.text :comentario

      t.timestamps
    end
  add_index :coments, :user_id
add_index :coments, :user_file_id
end
end
