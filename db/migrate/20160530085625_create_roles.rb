class CreateRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :roles do |t|
      t.integer :organization_id
      t.integer :project_id
      t.integer :user_id
      t.integer :role

      t.timestamps
    end
  end
end
