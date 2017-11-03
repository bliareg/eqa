FactoryGirl.define do
  factory :git_hub_setting do
    project_id { Project.first.id }
    repository_url 'https://github.com/subsensor/EasyQATest'
    access_token '171e9afa6b3a7cee5e053ce54a660fc065e3b689'
  end
end
