FactoryGirl.define do
  factory :test_plan do
    title { Faker::Book.title }
    description { Faker::StarWars.quote }

    factory :setup_test_plan do
      transient do
        test_modules_count 1
        test_cases_count 10
      end
      after :create do |instance, evaluator|
        evaluator.test_modules_count.times do
          create(
            :setup_test_module,
            test_plan_id: instance.id, created_by: instance.created_by,
            test_cases_count: evaluator.test_cases_count
          )
        end
      end
    end
  end
end
