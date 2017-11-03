class ChangeContryTypeInUsers < ActiveRecord::Migration[5.0]
  def self.up
    change_column :users, :country, :string
  end

  def self.down
    change_column :users, :country, :integer
  end
end
