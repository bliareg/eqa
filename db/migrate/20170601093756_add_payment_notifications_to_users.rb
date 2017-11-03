class AddPaymentNotificationsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :payment_notification_visible, :boolean, default: false
  end
end
