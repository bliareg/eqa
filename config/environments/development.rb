Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true
  config.action_cable.disable_request_forgery_protection = true
  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  config.log_tags = [:object_id]
  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  ############################ Action Mailer params
  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  config.action_mailer.perform_deliveries = true

  config.action_mailer.delivery_method = :letter_opener

  host_name = 'localhost'
  config.host_name = host_name

  config.action_mailer
        .default_url_options = { host: host_name, port: 3000 }

  config.action_mailer.smtp_settings = {
    address:              ENV['ACTION_MAILER_ADDRESS'],
    port:                 587,
    sdomain:              ENV['ACTION_MAILER_SDOMAIN'],
    authentication:       'plain',
    enable_starttls_auto: true,
    user_name:            ENV['SECRET_EMAIL'],
    password:             ENV['SECRET_EMAIL_PASSWORD'] }

  config.after_initialize do
    Bullet.enable = false
    Bullet.alert = false
    Bullet.bullet_logger = false
    Bullet.console = false
  #  Bullet.growl = true
    Bullet.rails_logger = false
    Bullet.add_footer = false
  end
end
