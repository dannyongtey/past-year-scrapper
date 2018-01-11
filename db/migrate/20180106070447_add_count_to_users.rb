class AddCountToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :count, :integer
  end
end
