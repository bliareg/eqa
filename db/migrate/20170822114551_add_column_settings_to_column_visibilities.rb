class AddColumnSettingsToColumnVisibilities < ActiveRecord::Migration[5.0]
  def change
    add_column :column_visibilities, :column_setting, :string
  end
end
