class AddFieldToStatistic < ActiveRecord::Migration[5.0]
  def change
    add_column :statistics, :sign_in_count, :integer, default: 1
  end
end
