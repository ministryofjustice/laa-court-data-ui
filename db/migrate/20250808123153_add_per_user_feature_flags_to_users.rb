class AddPerUserFeatureFlagsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :feature_flags, :string, default: [], array: true
  end
end
