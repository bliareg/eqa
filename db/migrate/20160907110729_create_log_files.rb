class CreateLogFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :log_files do |t|
      t.references :crash, foreign_key: true
      t.datetime :log_created_at

      t.timestamps
    end
  end
end
