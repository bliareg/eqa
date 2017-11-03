FactoryGirl.define do
  factory :issue do
    summary     { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    issue_type  { rand(0..6) }
    priority    { rand(0..3) }
  end
end
