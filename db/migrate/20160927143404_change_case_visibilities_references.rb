class ChangeCaseVisibilitiesReferences < ActiveRecord::Migration[5.0]
  def change
    remove_reference :case_visibilities, :test_module
    add_reference :case_visibilities, :test_plan, foreign_key: true, index: true
  end
end
