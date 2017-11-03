class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.string   :title
      t.integer  :user_id, index: true
      t.integer  :organization_id
      t.datetime :deleted_at
    end
  end
end
