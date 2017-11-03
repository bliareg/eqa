class AddLocaleToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :locale, :string, default: 'en'
    remove_column :users, :avatar_file_name, :string
    remove_column :users, :avatar_content_type, :string
    remove_column :users, :avatar_file_size, :integer
  end
end
