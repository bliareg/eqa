class CreateIosBuildPlists < ActiveRecord::Migration[5.0]
  def change
    create_table :ios_build_plists do |t|
      t.references :mobile_build, foreign_key: true

      t.timestamps
    end
  end
end
