class AddReferalsToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :referal_token, :string
    add_column :users, :referred_by, :integer
    add_index :users, :referal_token, unique: true
    add_index :users, :referred_by
    User.find_each do |user|
      user.referal_token = SecureRandom.urlsafe_base64(12)
      user.save
    end
  end

  def down
    remove_column :users, :referal_token, :string
    remove_column :users, :referred_by, :integer
  end
end
