class AddLockedAtUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :locked_at, :datetime
    add_index :users, :locked_at
  end
end
