namespace :db_maintenance do
  desc 'Add test_case id in project (after )'
  task :add_test_case_pid => :environment do


    Project.all.each do |project|

      p "Adding pid for project: #{project.id} #{project.title}"
      project.test_cases.each do |test_case|
        print '*'
        max_num = project.test_cases.order('id_in_project DESC').first.id_in_project
        test_case.id_in_project = max_num.nil? ? 1 : max_num + 1
        test_case.save
      end
    end

    p 'Finished.'
  end
end
