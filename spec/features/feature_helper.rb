require_relative 'feature_shared_examples'
require 'capybara/rspec'
require 'support/database_cleaner'
require 'capybara/poltergeist'

RSpec.configure do |config|
  Capybara.javascript_driver = :poltergeist

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app,
                                      timeout: 1.minute,
                                      phantomjs_options: ['--load-images=no'])
  end

  config.include Warden::Test::Helpers

  config.before :suite do
    Warden.test_mode!
  end

  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.include LoginMacros # , type: :feature
  config.include TestDataGenerators
end

