class CreateTempFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :temp_files do |t|
      t.string :path
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
