class CreateTrelloSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :trello_settings do |t|
      t.string :public_key
      t.string :member_token
      t.string :board_name
      t.string :service_board_id
      t.boolean :enable_synchronization, default: true
      t.integer :synchronization_type
      t.references :project, foreign_key: true
      t.references :user, foreign_key: true
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
