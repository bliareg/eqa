class AddTokenToPaypalPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :paypal_payments, :token, :string
  end
end
