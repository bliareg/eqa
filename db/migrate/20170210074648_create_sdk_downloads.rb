class CreateSdkDownloads < ActiveRecord::Migration[5.0]
  def change
    create_table :sdk_downloads do |t|
      t.integer :os
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
