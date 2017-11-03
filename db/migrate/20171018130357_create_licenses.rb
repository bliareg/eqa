class CreateLicenses < ActiveRecord::Migration[5.0]
  def change
    create_table :licenses do |t|
      t.text :token
      t.datetime :expire_at
      t.datetime :start_at
      t.integer :number_of_licenses
      t.string :email
      t.integer :license_id
      t.boolean :trial
      t.belongs_to :user

      t.timestamps
    end
  end
end
