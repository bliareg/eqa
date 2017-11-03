class AddTokenToOrganization < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations, :token, :string
    add_column :jwt_tokens, :token, :string
  end
end
