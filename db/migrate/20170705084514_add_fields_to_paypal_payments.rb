class AddFieldsToPaypalPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :paypal_payments, :period_start, :datetime
    add_column :paypal_payments, :period_end, :datetime
    add_column :paypal_payments, :standart_fee, :integer
  end
end
