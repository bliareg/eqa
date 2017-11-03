class RenameColumnFromCrashes < ActiveRecord::Migration[5.0]
  def change
    rename_column :crashes, :devise_serial, :device_serial
  end
end
