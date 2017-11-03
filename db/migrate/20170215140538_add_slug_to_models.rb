class AddSlugToModels < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :slug, :string
    add_index :projects, :slug, unique: true

    add_column :organizations, :slug, :string
    add_index :organizations, :slug, unique: true
  end
end
