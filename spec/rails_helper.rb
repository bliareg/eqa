
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'devise'
require 'paper_trail/frameworks/rspec'
require "pundit/rspec"

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
Dir[Rails.root.join('spec/shared_examples/*.rb')].each { |f| require f }

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec
    # Choose one or more libraries:
    with.library :active_record
    with.library :active_model
    with.library :action_controller
    # Or, choose the following (which implies all of the above):
    with.library :rails
  end
end

ActiveRecord::Migration.maintain_test_schema!
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true

  # https://relishapp.com/rspec/rspec-rails/docs
  config.include Devise::Test::ControllerHelpers, type: :controller
  # config.include Devise::TestHelpers, type: :controller
  config.include Devise::TestHelpers, type: :view
  config.include Devise::TestHelpers, type: :helper
  # config.extend ControllerMacros, :type => :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.infer_spec_type_from_file_location!
  config.include Warden::Test::Helpers
  # Include Factory Girl syntax to simplify calls to factories
  config.include FactoryGirl::Syntax::Methods

  config.include SpecHelpers
  config.include TestDataGenerators
end
