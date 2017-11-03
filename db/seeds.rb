# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Seeds run each time the server started
all_platforms = Platform.pluck(:name)
Platform::DEFAULT_PLATFORMS.each { |name| Platform.create(name: name) unless all_platforms.include?(name) }

all_statuses = Status.pluck(:name)
Status::DEFAULT_STATUSES.each_value do |params_status|
  Status.create(name: params_status[:name]) unless all_statuses.include?(params_status[:name])
end

ColumnSet.generate_default

AdminUser.create(email: ENV['ADMIN_EMAIL'],
                 superadmin: true,
                 password: ENV['ADMIN_PASSWORD'],
                 password_confirmation: ENV['ADMIN_PASSWORD']) if AdminUser.all.empty?

if Rails.env.demo?
  10.times { FactoryGirl.create(:demo_member) } if User.all.empty?
end
