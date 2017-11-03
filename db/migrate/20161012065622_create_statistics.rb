class CreateStatistics < ActiveRecord::Migration[5.0]
  def change
    create_table :statistics do |t|
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
