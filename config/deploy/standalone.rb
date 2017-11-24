lock '3.6.1'

server 'REMOTE_SERVER_IP',
        user: 'DEPLOY_USER',
        roles: [:web, :app, :db], primary: true

# Repo settings
set :scm, 'git'
set :repo_url, "https://github.com/thinkmobiles/EasyQA_standalone"
set :branch, 'master'
set :git_https_username, 'GIT_HTTPS_USERNAME'
set :git_https_password, 'GIT_HTTPS_PASSWORD'

set :deploy_to, '/home/deploy/www/eqa'

set :rbenv_ruby, '2.3.5'
set :stage, :standalone
set :rails_env, :standalone

# Default value for :linked_files is []
set :linked_files,
    fetch(:linked_files, []).push('config/database.yml', '.env',
                                  'config/sidekiq.yml')

# Default value for linked_dirs is []
set :linked_dirs,
    fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system')

set :pty,  false
set :sidekiq_env, 'standalone'
set :sidekiq_config, "#{shared_path}/config/sidekiq.yml"
