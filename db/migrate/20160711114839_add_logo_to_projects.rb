class AddLogoToProjects < ActiveRecord::Migration[5.0]
  def change
    change_table :projects do |t|
      t.attachment :logo
    end
  end
end
