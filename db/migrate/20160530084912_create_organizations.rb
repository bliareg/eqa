class CreateOrganizations < ActiveRecord::Migration[5.0]
  def change
    create_table :organizations do |t|
      t.string     :title
      t.text       :description
      t.attachment :logo
      t.datetime   :deleted_at
    end
  end
end
