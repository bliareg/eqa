class CreatePlugins < ActiveRecord::Migration[5.0]
  def change
    create_table :plugins do |t|
      t.string :name
      t.references :integratable, polymorphic: true
      t.references :setting, polymorphic: true
      t.string :service_id
      t.boolean :enable, default: true

      t.timestamps
    end
  end
end
