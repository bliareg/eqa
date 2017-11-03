FactoryGirl.define do
  factory :jira_setting do
    project_id { Project.first.id }
    base_url 'https://ubuntest.atlassian.net'
    username 'admin'
    password 'qwertyui'
    project_key 'UBUN'
    board_name 'UBUN board'
  end
end
