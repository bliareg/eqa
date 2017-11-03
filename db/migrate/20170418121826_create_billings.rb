class CreateBillings < ActiveRecord::Migration[5.0]
  def change
    create_table :billings do |t|
      t.integer  :user_id,             null: false
      t.integer  :licenses_amount,     null: false, default: 1
      t.datetime :expired_at,          null: false
      t.datetime :prev_expired_at
      t.boolean  :autopayment,         null: false, default: false
      t.integer  :plan_id,             null: false
      t.string   :btree_customer_id,   null: false
      t.boolean  :trial_period,        null: false, default: true
      t.integer  :default_payment_method_id

      t.timestamps
    end
  end
end
