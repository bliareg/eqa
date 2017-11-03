FactoryGirl.define do
  factory :test_module do
    title { Faker::StarWars.planet }
    description { Faker::Yoda.quote }

    factory :setup_test_module do
      transient do
        test_cases_count 10
      end
      after :create do |instance, evaluator|
        evaluator.test_cases_count.times do
          create(
            :test_case,
            test_plan_id: instance.test_plan_id, created_by: instance.created_by,
            module_id: instance.id
          )
        end
      end
    end
  end
end
