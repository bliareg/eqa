class CreatePromocodes < ActiveRecord::Migration[5.0]
  def change
    create_table :promocodes do |t|
      t.integer :max_number_of_uses, default: 1
      t.integer :number_of_uses, default: 0
      t.integer :number_of_licenses, default: 0
      t.integer :discount
      t.string :token

      t.timestamps
    end
  end
end
