class RenameColumnInUsers < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :referal_token, :referral_token
  end
end
