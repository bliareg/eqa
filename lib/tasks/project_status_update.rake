namespace :db_maintenance do
  desc 'Fill project_statuses position column with values after 9ecdc271c1ca11d45bce4c48e2feac26ca2851fa'
  task :fill_position_with_values  => :environment do
    p 'Starting to fill values'
    Project.all.each do |project|
      p project.id
      project.project_statuses.each_with_index do |status, i|
        print '.'
        status.update(position: (i + 1))
      end
    end
  end
end
