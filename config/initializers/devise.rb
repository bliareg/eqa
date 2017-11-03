Devise.setup do |config|
  config.mailer_sender = 'admin@geteasyqa.com'
  config.secret_key = ENV['DEVISE_SECRET_KEY']

  require 'devise/orm/active_record'

  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 11
  config.reconfirmable = false
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 6..128
  config.email_regexp = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete

  config.warden do |manager|
    manager.failure_app = CustomFailure
  end

  require "omniauth-facebook"
  require "omniauth-google-oauth2"
  require 'omniauth-linkedin-oauth2'

  if Rails.env.development?
    HOST = 'http://localhost:3000/users/auth/'.freeze
  elsif Rails.env.staging?
    HOST = 'http://qa_dashboard.test.thinkmobiles.com:8085/users/auth/'.freeze
  else
    HOST = "https://#{Rails.application.config.host_name}/users/auth/".freeze
  end

  unless Rails.env.standalone?

    config.omniauth :facebook,
                    ENV['SECRET_FACEBOOK_ID'],
                    ENV['SECRET_FACEBOOK_KEY'],
                    callback_url: HOST + "facebook/callback",
                    secure_image_url: true

    config.omniauth :google_oauth2,
                    ENV['SECRET_GOOGLE_ID'],
                    ENV['SECRET_GOOGLE_KEY'],
                    image_aspect_ratio: 'original',
                    redirect_uri: HOST + "google_oauth2/callback",
                    provider_ignores_state: true,
                    prompt: 'select_account',
                    scope: 'email, profile, https://www.googleapis.com/auth/contacts.readonly'

    config.omniauth :linkedin,
                    ENV['SECRET_LINKEDIN_ID'],
                    ENV['SECRET_LINKEDIN_KEY'],
                    callback_url: HOST + "linkedin/callback"
  end
end
