class CreateUnlinkReasons < ActiveRecord::Migration[6.0]
  def change
    create_table :unlink_reasons do |t|
      t.integer :code, null: false, index: { unique: true }
      t.string :description, null: false, index: { unique: true }
      t.boolean :text_required, null: false, default: false
      t.timestamps
    end
  end
end
