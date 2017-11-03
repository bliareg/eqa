class CreateMobileBuilds < ActiveRecord::Migration[5.0]
  def change
    create_table :mobile_builds do |t|
      t.attachment :file
      t.references :project
      t.references :user

      t.timestamps
    end
  end
end
