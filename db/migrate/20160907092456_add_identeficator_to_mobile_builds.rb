class AddIdenteficatorToMobileBuilds < ActiveRecord::Migration[5.0]
  def change
    add_column :mobile_builds, :identeficator, :string
  end
end
