class AddMonthsToPaypalPayments < ActiveRecord::Migration[5.0]
  def up
    add_column :paypal_payments, :number_of_months, :integer
    Billing.find_each do |billing|
      pp = billing.paypal_payments.first
      pp.update_attribute(:regular, true) if pp
    end
    PaypalPayment.where(regular: true).each{ |pp| pp.update_attribute(:number_of_months, 1) }
  end

  def down
    remove_column :paypal_payments, :number_of_months, :integer
  end
end
