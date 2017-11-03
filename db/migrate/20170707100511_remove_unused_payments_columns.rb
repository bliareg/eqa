class RemoveUnusedPaymentsColumns < ActiveRecord::Migration[5.0]
  def up
    remove_column :billings, :plan_id, :integer
    remove_column :users, :braintree_customer_id, :string
    change_column :billings, :btree_customer_id, :string, null: true
    drop_table :plans
  end

  def down
    add_column :billings, :plan_id, :integer
    add_column :users, :braintree_customer_id, :string
    change_column :billings, :btree_customer_id, :string, null: false
    create_table :plans do |t|
      t.string  :title,               null: false
      t.integer :license_price,       null: false
      t.integer :min_licenses_amount, null: false
      t.integer :max_licenses_amount, null: false

      t.timestamps
    end
  end
end
