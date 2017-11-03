class CreateJoinTablePlatformProject < ActiveRecord::Migration[5.0]
  def change
    create_join_table :platforms, :projects do |t|
      # t.index [:platform_id, :project_id]
      # t.index [:project_id, :platform_id]
    end
  end
end
