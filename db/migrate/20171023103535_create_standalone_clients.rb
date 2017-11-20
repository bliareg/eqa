class CreateStandaloneClients < ActiveRecord::Migration[5.0]
  def up
    create_table :standalone_clients do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :country
      t.string :state
      t.string :city
      t.string :street_address
      t.string :company
      t.string :zip_code
      t.string :phone_number
      t.string :token
      t.boolean :trial_period, default: false
      t.datetime :prev_expired_at
      t.datetime :expired_at

      t.timestamps
    end

    add_reference :paypal_payments, :payerable, polymorphic: true
    PaypalPayment.all.each do |pp|
      pp.update_columns(payerable_type: 'Billing', payerable_id: pp.billing_id)
    end
    remove_reference :paypal_payments, :billing
    add_column :promocodes, :for_standalone, :boolean, default: false

    create_table :standalone_licenses do |t|
      t.references :standalone_client, foreign_key: true
      t.references :paypal_payment, foreign_key: true
      t.integer :number_of_licenses
      t.datetime :period_start
      t.datetime :period_end
      t.boolean :trial_period, default: false
      t.string :token
      t.timestamps
    end
  end

  def down
    drop_table :standalone_licenses
    add_reference :paypal_payments, :billing
    PaypalPayment.all.each do |pp|
      pp.update_columns(billing_id: pp.payerable_id)
    end
    remove_reference :paypal_payments, :payerable, polymorphic: true
    remove_column :promocodes, :for_standalone, :boolean

    drop_table :standalone_clients
  end
end
