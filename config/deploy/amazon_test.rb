server 'ec2-52-59-230-164.eu-central-1.compute.amazonaws.com',
       user: 'ubuntu',
       roles: [:web, :app, :db],
       primary: true

# ssh_options[:forward_agent] = true
# set :ssh_options, {:forward_agent => true}
set :application, 'QualityDashboard'
set :repo_url, 'git@git.thinkmobiles.com:RubyOnRails/quality_dashboard.git'
set :branch, 'develop'
set :stage, "production"
# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'
set :deploy_to, '/var/www/easyqa'
set :rbenv_ruby, '2.3.1'

set :linked_files,
    fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs,
    fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache',
                                 'tmp/sockets', 'public/system')

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
