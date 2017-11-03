class CreateCaseVisibilities < ActiveRecord::Migration[5.0]
  def change
    create_table :case_visibilities do |t|
      t.references :user, foreign_key: true
      t.references :test_module, foreign_key: true
      t.references :show_column, foreign_key: true, default: 1

      t.timestamps
    end
  end
end
