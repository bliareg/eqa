require_relative 'boot'

require 'rails/all'
require 'cfpropertylist'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module QualityDashboard
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.without_whitespaces = /\A\S*\z/s
    config.to_prepare { Devise::SessionsController.respond_to :js, only: :create }
    config.locales = [['EN', 'en'], ['EG', 'eg']]

    config.generators do |g|
      g.test_framework :rspec,
      fixtures: true,
      view_specs: false,
      helper_specs: false,
      routing_specs: true,
      controller_specs: true,
      request_specs: false
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end
    config.eager_load_paths += %W( #{config.root}/lib/presenter_modules )
    config.autoload_paths += %W(#{config.root}/lib/devise_failure)

    config.after_initialize do
      load Rails.root + 'db/seeds.rb' if ENV['RACK_ENV']
    end

    def self.autoload_deep(folder_path)
      Dir[folder_path + '/*'].each do |f|
        config.autoload_paths << f
      end
    end

    autoload_deep 'app/services'
    autoload_deep 'app/workers/concerns'
    require './app/services/countries_i18n_fix/data'
    require './app/services/friendly_id_parameterize'
    require './app/services/paperclip_attachment'
  end
end
