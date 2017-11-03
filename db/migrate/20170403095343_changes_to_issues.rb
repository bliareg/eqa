class ChangesToIssues < ActiveRecord::Migration[5.0]
  def change
    remove_column :issues, :priority, :integer
    rename_column :issues, :severity, :priority
  end
end
