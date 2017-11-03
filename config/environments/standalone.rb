Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.cache_classes = true
  config.eager_load = true
  config.action_cable.disable_request_forgery_protection = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.assets.js_compressor = :uglifier
  config.assets.compile = false
  config.assets.debug = false
  config.log_level = :debug
  config.log_tags = [ :request_id ]
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false

  ############################ Action Mailer params
  config.action_mailer.perform_caching = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp

  host_name = ENV['APP_DOMAIN']
  config.host_name = host_name
  config.action_mailer
        .default_url_options = { host: host_name,
                                 protocol: "http://" }

  config.action_mailer.smtp_settings = {
    address:              ENV['ACTION_MAILER_ADDRESS'],
    port:                 587,
    sdomain:              ENV['ACTION_MAILER_SDOMAIN'],
    authentication:       'plain',
    enable_starttls_auto: true,
    user_name:            ENV['SECRET_EMAIL'],
    password:             ENV['SECRET_EMAIL_PASSWORD'] }
end
