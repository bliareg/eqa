class AddTokenToProject < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :token, :string
  end
end
