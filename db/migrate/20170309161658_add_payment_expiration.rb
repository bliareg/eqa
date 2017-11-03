class AddPaymentExpiration < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :is_payment_expired, :boolean, default: false
    add_column :users, :is_payment_expiring, :boolean, default: false
    add_column :users, :expired_at, :datetime
    add_column :organizations, :is_payment_expired, :boolean, default: false
    add_column :organizations, :is_payment_expiring, :boolean, default: false
  end
end
