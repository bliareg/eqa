source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.0.1'
gem 'encrypted_strings'
# Use sqlite3 as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'turbolinks', '~> 5.x'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
gem 'jquery-ui-rails'
gem 'paper_trail'
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'faraday', '~> 0.9.2'
gem 'faraday_middleware', '~> 0.10.0'
gem 'sidekiq_status', '~> 1.1'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7', platforms: :ruby
gem 'dropzonejs-rails'
gem 'awesome_nested_set'
gem 'u_presenter'
gem 'pundit', '~> 1.1'
gem 'chartjs-ror'
gem 'gon'
gem 'ruby_apk'
gem 'rspec_api_documentation', '~> 4.7'
gem 'apitome'
gem 'plist'
gem 'CFPropertyList'
gem 'client_side_validations'
gem 'country_select'
# Use Capistrano for deployment
gem 'activeadmin', github: 'activeadmin'
gem 'inherited_resources', github: 'activeadmin/inherited_resources'
gem 'chartkick', '>= 2.1.1'
gem 'groupdate', '~> 2.0'
gem 'chosen-rails'
gem 'jira-ruby', '>= 1.1.3'
gem 'dotenv-rails', '~> 2.2'
gem 'friendly_id', '~> 5.1.0'
gem 'paypal-sdk-rest'
gem 'jwt'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'awesome_print'
  gem 'letter_opener'
  gem 'rspec-rails'
  gem 'poltergeist', '~> 1.10'
  # gem 'capybara-webkit'
  gem 'database_cleaner'
  # gem 'rack-mini-profiler'
  gem 'bullet'
  gem 'shoulda-matchers', '~> 3.0'
end

group :development, :test, :demo do
  gem 'factory_girl_rails'
  gem 'faker'
end

# group :production do
#   gem 'secure_headers'
# end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  # gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.0', '>= 2.0.1'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'capistrano-rails', require: false
  gem 'rails-erd'
  gem 'capistrano-rbenv', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-sidekiq', '~> 0.10.0', require: false
  gem 'guard-rspec', '~> 4.7', '>= 4.7.3', require: false
  gem 'spring-commands-rspec', group: :development
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'devise'
gem 'enumerize'
gem 'paranoia', github: 'rubysherpas/paranoia', branch: 'rails4'
gem 'paperclip', '~> 5.0.0.beta1'
gem 'kaminari'

# social login
gem 'omniauth-oauth2', '1.3.1'
gem 'omniauth-google-oauth2'
gem 'omniauth-linkedin-oauth2'
gem 'omniauth-facebook'
# gem 'remotipart'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'
gem 'atlassian-jwt-authentication',
                git: 'https://github.com/MeisterLabs/atlassian-jwt-authentication.git',
                require: 'atlassian_jwt_authentication'
gem 'braintree', '~> 2.74.0'
gem 'wdm', '>= 0.1.0' if Gem.win_platform?
