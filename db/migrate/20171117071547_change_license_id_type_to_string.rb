class ChangeLicenseIdTypeToString < ActiveRecord::Migration[5.0]
  def up
    change_column :licenses, :license_id, :string
    add_column :standalone_licenses, :token_id, :string
    add_column :standalone_licenses, :host_ip, :string
  end

  def down
    remove_column :standalone_licenses, :host_ip
    remove_column :standalone_licenses, :token_id
    change_column :licenses, :license_id, 'integer USING CAST(license_id AS integer)'
  end
end
