class CreateShowColumns < ActiveRecord::Migration[5.0]
  def change
    create_table :show_columns do |t|
      t.string :names, array: true, default: []

      t.timestamps
    end
    add_index :show_columns, :names, using: :gin
  end
end
