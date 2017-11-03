FactoryGirl.define do
  factory :you_track_setting do
    base_url 'https://batman.myjetbrains.com/youtrack/'
    login 'ihor2405@gmail.com'
    password '1234567890'
    service_pid 'T2'
    agile_board_name 'new board'
    sprint_name 'First sprint'
  end
end
