class AddPromocodesToPaypalPayments < ActiveRecord::Migration[5.0]
  def change
    add_reference :paypal_payments, :promocode, foreign_key: true
  end
end
