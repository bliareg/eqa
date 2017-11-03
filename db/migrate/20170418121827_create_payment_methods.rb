class CreatePaymentMethods < ActiveRecord::Migration[5.0]
  def change
    create_table :payment_methods do |t|
      t.references :billing, foreign_key: true
      t.string :token
      t.string :img_url
      t.string :text
      t.boolean :default
      t.datetime :deleted_at
      
      t.timestamps
    end
  end
end
