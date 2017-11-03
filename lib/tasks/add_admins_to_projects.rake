namespace :db_maintenance do
  desc 'Add admins to existing projects after 2eec3a93f7caa1e48849fd2f254ac9d1791163ec'
  task :add_necessary_admins => :environment do

    Role.where(project_id: nil, role: Role.admin_value).each do |admin_role|

      p "Adding roles for admin_role: #{admin_role}"

      old_project_ids = []

      Role.where(user_id: admin_role.user_id,
                 organization_id: admin_role.organization_id)
          .where.not(project_id: nil).each do |new_admin_role|

        old_project_ids.push(new_admin_role.project_id)
        new_admin_role.update(role: Role.admin_value)
      end

      project_ids = Organization.find_by_id(admin_role.organization_id).project_ids - old_project_ids

      current_organization = admin_role.organization

      p "creating roles for #{current_organization.title}"

      project_ids.each do |project_id|

        p "Adding role for project with id: #{project_id}"

        Role.create(user_id: admin_role.user_id,
                    organization_id: current_organization.id,
                    project_id: project_id,
                    role: Role.admin_value)
        ProjectNotification.create(user_id: admin_role.user_id, project_id: project_id)

        TestPlan.where(project_id: project_id).each do |test_plan|
          CaseVisibility.create(user_id: admin_role.user_id,
                                test_plan_id: test_plan.id)
        end
      end
    end

  end
end
