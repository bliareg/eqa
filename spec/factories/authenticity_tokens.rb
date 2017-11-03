FactoryGirl.define do
  factory :authenticity_token do
    sequence(:token) { |n| SecureRandom.base64(24) + n.to_s }
    user nil
  end
end
