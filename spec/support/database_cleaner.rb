RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    # load "#{Rails.root}/db/seeds.rb"
  end

  # config.before(:each)       { DatabaseCleaner.strategy = :truncation }
  config.before(:each)       { DatabaseCleaner.strategy = :transaction }

  config.before(:each,
                js: true)    { DatabaseCleaner.strategy = :truncation }

  config.before(:each)       { DatabaseCleaner.start }
  config.append_after(:each) { DatabaseCleaner.clean }
end
