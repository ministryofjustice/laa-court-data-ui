class AddUniqueReferenceToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :unique_user_reference, :string, null: false
    add_index :users, :unique_user_reference, unique: true
  end
end
