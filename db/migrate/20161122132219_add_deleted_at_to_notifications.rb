class AddDeletedAtToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :deleted_at, :datetime
  end
end
