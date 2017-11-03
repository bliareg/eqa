namespace :db_maintenance do
  desc 'Fill statistics table with initial data after 1c11c2bd8039a09bf23d3fff5e08e686b13786a8'
  task :init_statistics => :environment do

    p 'Fill initial data to statistics table'

    User.where.not(last_sign_in_at: nil).each do |user|
      print '*'
      Statistic.create(user_id: user.id,
                       created_at: user.last_sign_in_at)
    end

    p 'Finished.'
  end
end
