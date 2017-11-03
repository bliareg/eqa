class ChangeColmunName < ActiveRecord::Migration[5.0]
  def change
    rename_column :trello_settings, :public_key, :api_key
  end
end
