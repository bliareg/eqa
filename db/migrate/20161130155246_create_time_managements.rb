class CreateTimeManagements < ActiveRecord::Migration[5.0]
  def change
    create_table :time_managements do |t|
      t.datetime :spent_time
      t.references :user, foreign_key: true
      t.references :issue, foreign_key: true
      t.string :comment

      t.timestamps
    end

    add_column :issues, :spent_time, :datetime, default: Time.at(0).to_datetime
  end
end
