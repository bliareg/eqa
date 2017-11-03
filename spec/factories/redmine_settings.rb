FactoryGirl.define do
  factory :redmine_setting do
    project_id { Project.first.id }
    base_url 'http://thinktest.m.redmine.org/'
    api_key '4c6c9ba9fdb2284dbd158fd6983ea897bd78e2b9'
    project_name 'Test'
    tracker_name 'Tracker'
  end
end
