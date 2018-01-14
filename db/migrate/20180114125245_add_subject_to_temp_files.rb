class AddSubjectToTempFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :temp_files, :subject, :string
  end
end
