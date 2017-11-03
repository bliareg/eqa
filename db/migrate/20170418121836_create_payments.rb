class CreatePayments < ActiveRecord::Migration[5.0]
  def change
    create_table :payments do |t|
      t.references :billing, foreign_key: true
      t.references :payment_method, foreign_key: true
      t.integer :status
      t.string :btree_transaction_id
      t.float :amount
      t.boolean :regular
      t.integer :licenses_amount
      t.string :error_message

      t.timestamps
    end
  end
end
