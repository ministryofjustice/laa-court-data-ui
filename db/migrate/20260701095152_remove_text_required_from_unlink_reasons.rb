class RemoveTextRequiredFromUnlinkReasons < ActiveRecord::Migration[8.1]
  def change
    remove_column :unlink_reasons, :text_required, :boolean
  end
end
