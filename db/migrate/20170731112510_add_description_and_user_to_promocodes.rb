class AddDescriptionAndUserToPromocodes < ActiveRecord::Migration[5.0]
  def change
    add_column :promocodes, :description, :string
    add_reference :promocodes, :user, foreign_key: true
  end
end
