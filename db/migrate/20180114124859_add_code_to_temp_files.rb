class AddCodeToTempFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :temp_files, :code, :integer
  end
end
