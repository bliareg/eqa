class CreatePlans < ActiveRecord::Migration[5.0]
  def change
    create_table :plans do |t|
      t.string  :title,               null: false
      t.integer :license_price,       null: false
      t.integer :min_licenses_amount, null: false
      t.integer :max_licenses_amount, null: false

      t.timestamps
    end
  end
end
