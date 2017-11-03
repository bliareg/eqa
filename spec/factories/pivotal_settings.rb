FactoryGirl.define do
  factory :pivotal_setting do
    project_id { Project.first.id }
    project_name 'Test'
    api_token '35b39eaeb880d1d73f76f0674f94a1b6'
  end
end
