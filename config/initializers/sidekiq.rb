if Rails.env.standalone?
  schedule_file = 'config/standalone_schedule.yml'
else
  schedule_file = 'config/schedule.yml'
end

if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end

Sidekiq.configure_client do |config|
  config.redis = { namespace: 'EasyQADemo', url: 'redis://127.0.0.1:6379/1' } if Rails.env.demo?
end

Sidekiq.configure_server do |config|
  config.redis = { namespace: 'EasyQADemo', url: 'redis://127.0.0.1:6379/1' } if Rails.env.demo?
end
