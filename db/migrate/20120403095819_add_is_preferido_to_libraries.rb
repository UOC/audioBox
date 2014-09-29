class AddIsPreferidoToLibraries < ActiveRecord::Migration
  def change
    add_column :libraries, :is_preferido, :booleand
  end
end
