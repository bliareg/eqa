FactoryGirl.define do
  factory :test_case do
    title { Faker::Space.galaxy }
    pre_steps { "1. Find #{Faker::StarWars.character} \n 2. Give him #{Faker::StarWars.specie}" }
    steps { "1. Sit in a #{Faker::StarWars.vehicle}\n 2. Go to #{Faker::StarWars.planet}" }
    expected_result { "droid '#{Faker::StarWars.droid}' say '#{Faker::StarWars.quote}'" }
    case_type 2
  end
end
