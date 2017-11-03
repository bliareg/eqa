namespace :db_maintenance do
  desc 'Reconnect_columns_to_plans after d16ae2d8e0fba5951bffe90861c9ee7ff74a0ee2'
  task :reconnect_columns_to_plans  => :environment do

    p 'Remove all case visibilities'
    CaseVisibility.destroy_all
    p 'Remove all show_columns except 1'
    ShowColumn.where.not(id: 1).destroy_all
    p 'Create new case visibilities'
    User.all.each do |user|
      Role.where(user_id: user.id).where.not(project_id: nil).pluck(:project_id).each do |project_id|
        Project.find_by_id(project_id).test_plans.each do |test_plan|
          CaseVisibility.create(user_id: user.id, test_plan_id: test_plan.id)
        end
      end
    end

  end
end
