class CreateYouTrackSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :you_track_settings do |t|
      t.references :project, foreign_key: true
      t.references :user, foreign_key: true
      t.string :base_url
      t.boolean :enable_synchronization, default: true
      t.integer :synchronization_type
      t.string :login
      t.string :password
      t.string :service_pid
      t.string :agile_board_name
      t.string :sprint_name

      t.timestamps
    end
  end
end
