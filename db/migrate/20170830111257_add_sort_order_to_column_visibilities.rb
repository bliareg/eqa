class AddSortOrderToColumnVisibilities < ActiveRecord::Migration[5.0]
  def change
    add_column :column_visibilities, :sort_order, :string
  end
end
