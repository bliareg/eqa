FactoryGirl.define do
  factory :test_run do
    title { Faker::Book.title }
    description { Faker::StarWars.quote }
  end
end
