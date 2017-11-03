class CreatePaypalPayments < ActiveRecord::Migration[5.0]
  def change
    create_table :paypal_payments do |t|
      t.references :billing, foreign_key: true
      t.integer :licenses_amount
      t.float :amount
      t.boolean :regular
      t.integer :status
      t.string :paypal_id
      t.string :paypal_sale_id
      t.string :error_message

      t.timestamps
    end
  end
end
