class ChangeColorFormatInStatuses < ActiveRecord::Migration[5.0]
  def change
    change_column :statuses, :color, :string
  end
end
