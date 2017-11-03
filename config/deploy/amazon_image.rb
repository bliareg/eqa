lock '3.6.1'

server '52.11.27.94',
       user: 'ubuntu',
       roles: [:web, :app, :db], primary: true

set :repo_url, 'git@git.thinkmobiles.com:RubyOnRails/quality_dashboard.git'
set :branch, 'develop'

set :deploy_to, '/home/ubuntu/www/easy_qa'
set :rbenv_ruby, '2.3.1'

set :rails_env, :production

# # Default value for :linked_files is []
# set :linked_files,
#     fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml',
#                                   'config/sidekiq.yml')

# Default value for linked_dirs is []
set :linked_dirs,
    fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system')

set :use_sudo, true
set :pty,  false
set :sidekiq_env, 'production'
set :sidekiq_config, "#{shared_path}/config/sidekiq.yml"

namespace :database do
  desc 'Runs rake db:setup'
  task :setup do
    on fetch(:migration_servers) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          begin
            info 'Create database'
            execute :rake, 'db:setup'
          rescue
            info 'Database already create'
          end
        end
      end
    end
  end

  after 'bundler:install', 'database:setup'
end
