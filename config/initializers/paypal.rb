unless Rails.env.standalone?
  PayPal::SDK.load("config/paypal.yml", Rails.env)
  PayPal::SDK.logger = Rails.logger
end
