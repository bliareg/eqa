class ChangeCaseVisibilityAndShowColumn < ActiveRecord::Migration[5.0]
  def up
    rename_table :case_visibilities, :column_visibilities
    rename_table :show_columns, :column_sets

    remove_index :column_visibilities, :test_plan_id
    remove_foreign_key :column_visibilities, column: :test_plan_id


    remove_foreign_key :column_visibilities, column: :show_column_id
    rename_column :column_visibilities, :show_column_id, :column_set_id
    add_foreign_key :column_visibilities, :column_sets, column: :column_set_id

    add_column :column_visibilities, :columnable_type, :string
    rename_column :column_visibilities, :test_plan_id, :columnable_id

    change_column_default :column_visibilities, :column_set_id, nil

    migrate_data
  end

  def down
    rename_table :column_sets, 'show_columns'
    rename_table :column_visibilities, 'case_visibilities'

    rename_column :case_visibilities, :columnable_id, :test_plan_id

    remove_foreign_key :case_visibilities, column: :column_set_id
    rename_column :case_visibilities, :column_set_id, :show_column_id
    add_foreign_key :case_visibilities, :show_columns

    remove_column :case_visibilities, :columnable_type
    change_column_default :case_visibilities, :show_column_id, 1

    add_foreign_key :case_visibilities, :test_plans
    add_index :case_visibilities, :test_plan_id
  end

  def migrate_data
    ColumnSet.generate_default
    update_test_plan_column_visibilities
    generate_test_run_visibilities
    destroy_column_set_dups
  end

  private

  def update_test_plan_column_visibilities
    ColumnVisibility.where(columnable_type: nil)
                    .where.not(columnable_id: nil)
                    .update_all(columnable_type: TestPlan.to_s)
  end

  def generate_test_run_visibilities
    iterate_users do |project, user|
      project.test_runs.each do |test_run|
        test_run.column_visibilities.create(
          user: user,
          column_set: ColumnSet.default_for(TestRun)
        ) unless test_run.column_visibility(user)
      end
    end
  end

  def iterate_users
    Project.find_each do |project|
      Project.members_by_project_id(project.id)
             .each { |user| yield(project, user) }
    end
  end

  def destroy_column_set_dups
    ColumnSet.all.group_by(&:names).each_value do |column_sets|
      column_sets[1..-1].each do |column_set|
        column_set.column_visibilities.update_all(column_set_id: column_sets[0].id)
      end
      column_sets[1..-1].each(&:destroy)
    end
  end
end
