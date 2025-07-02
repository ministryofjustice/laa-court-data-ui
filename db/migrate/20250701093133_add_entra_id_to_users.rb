class AddEntraIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :entra_id, :string
  end
end
