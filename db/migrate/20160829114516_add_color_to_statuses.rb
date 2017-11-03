class AddColorToStatuses < ActiveRecord::Migration[5.0]
  def change
    add_column :statuses, :color, :integer
  end
end
