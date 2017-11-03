server '192.168.88.241',
       user: 'thinkmobiles',
       roles: [:web, :app, :db], primary: true
# server '194.42.200.114:8085, user: 'thinkmobiles', roles: [:web, :app, :db], primary: true

lock '3.6.1'

set :application, 'QualityDashboard'
set :repo_url, 'git@git.thinkmobiles.com:RubyOnRails/quality_dashboard.git'
# Default branch is :master
set :branch, 'develop'

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'
set :deploy_to, '/var/www/demo_easy_qa'
set :rbenv_ruby, '2.3.0'

set :stage, :demo
set :rails_env, :demo

# Default value for :linked_files is []
set :linked_files,
    fetch(:linked_files, []).push('config/database.yml', '.env',
                                  'config/sidekiq.yml')
    # fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs,
    fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system')

set :pty,  false
set :sidekiq_env, 'demo'
set :sidekiq_config, "#{shared_path}/config/sidekiq.yml"
# set :sidekiq_config, -> { File.join(shared_path, 'config', 'sidekiq.yml') }

# set :passenger_restart_command,
#   ->{ "passenger-config restart-app --instance o7G2ma5T" }

# namespace :db do

#   task :db_reset_task do
#     # rails_env = 'production'
#     execute "cd #{current_path} && bundle exec rake db:reset RAILS_ENV=#{rails_env}"
#   end
# end

# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server 'example.com', user: 'deploy', roles: %w{app db web}, my_property: :my_value
# server 'example.com', user: 'deploy', roles: %w{app web}, other_property: :other_value
# server 'db.example.com', user: 'deploy', roles: %w{db}

# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any  hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :app, %w{deploy@example.com}, my_property: :my_value
# role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
# role :db,  %w{deploy@example.com}

# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
