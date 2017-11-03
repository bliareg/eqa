class CreateCrashes < ActiveRecord::Migration[5.0]
  def change
    create_table :crashes do |t|
      t.references :mobile_build, foreign_key: true
      t.string :os_version
      t.string :device
      t.string :device_model
      t.string :device_brand
      t.string :device_manufacturer
      t.string :devise_serial

      t.timestamps
    end
  end
end
