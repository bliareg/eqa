namespace :db_maintenance do
  desc 'Create superadmin from account after 1c11c2bd8039a09bf23d3fff5e08e686b13786a8'
  task :create_super_admin => :environment do

    AdminUser.find_by(email: 'easyqa.admin@thinkmobiles.com')
             .update(superadmin: true)

    p 'Superadmin was created.'

  end
end
