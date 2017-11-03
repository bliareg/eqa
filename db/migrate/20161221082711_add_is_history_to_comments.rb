class AddIsHistoryToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :is_history, :boolean, default: false
  end
end
