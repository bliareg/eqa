FactoryGirl.define do
  factory :demo_setup, class: User do
    first_name 'Demo'
    last_name 'User'
    company { Faker::Company.name }
    sequence(:email) { |n| "#{(Faker::Name.first_name + '_' + Faker::Name.last_name).parameterize + n.to_s}@demo.com" }
    password 'foobarrr'
    password_confirmation 'foobarrr'

    after :create do |instance|
      instance.confirm
      Thread.current[:user_id] = instance.id
      create(:demo_organization, main_user_id: instance.id)
    end
  end

  factory :demo_member, class: User do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    company { Faker::Company.name }
    email { "#{name.parameterize}@demo.com" }
    password 'foobarrr'
    password_confirmation 'foobarrr'
  end

  factory :demo_organization, class: Organization do
    transient do
      main_user_id nil
    end
    title { Faker::Company.name + ' ' + Faker::Company.suffix }
    description { "#{title} - the best company in the world." }

    after :create do |instance, evaluator|
      (1..2).each { |index| create(:role_admin, user_id: index, organization_id: instance.id) }
      (3..10).each { |index| create(:role_user, user_id: index, organization_id: instance.id) }
      # 2.times {
        create(:demo_project, organization_id: instance.id, user_id: evaluator.main_user_id)
      # }
    end
  end

  factory :demo_project, class: Project do
    title { Faker::App.name }
    sequence(:token) { |n| SecureRandom.base64(24) + n.to_s }

    after :create do |instance, evaluator|
      roles = [:role_developer, :role_tester, :role_viewer, :role_project_manager]
      statuses = instance.project_statuses.pluck(:status_id)
      (3..10).each { |index| create(roles.sample, user_id: index, organization_id: instance.organization_id, project_id: instance.id) }
      create(:demo_object, project_id: instance.id, statuses: statuses)
      create(:demo_plan, project_id: instance.id)

      7.times { create(:demo_issue, project_id: instance.id, main_user_id: instance.user_id, statuses: statuses) }
      create(:demo_run, project_id: instance.id)
    end
  end

  factory :demo_object, class: TestObject do
    transient do
      statuses nil
    end
    user_id { rand(1..10) }
    created_at { rand(1..14).days.ago }

    before :create do |instance|
      PaperTrail.whodunnit = instance.user_id.to_s
      instance.file = File.new("#{Rails.root}/spec/fixtures/mobile_builds/app-debug.apk")
    end

    after :create do |instance, evaluator|
      PaperTrail.whodunnit = nil
      2.times { create(:demo_crash, test_object_id: instance.id,
                                    project_id: instance.project_id,
                                    statuses: evaluator.statuses) }
    end
  end

  factory :demo_crash, class: Crash do
    transient do
      project_id nil
      statuses nil
    end
    os_version '7.0'
    device 'vbox86p'
    device_model 'Nexus 5X API 23'
    device_brand 'Android'
    device_manufacturer 'Genymotion'
    device_serial { Faker::Code.imei }

    before :create do |instance|
      PaperTrail.whodunnit = rand(1..10).to_s
    end

    after :create do |instance, evaluator|
      PaperTrail.whodunnit = nil
      2.times { create(:demo_log_file, crash_id: instance.id,
                                       project_id: evaluator.project_id,
                                       statuses: evaluator.statuses) }
    end
  end

  factory :demo_log_file, class: LogFile do
    transient do
      project_id nil
      statuses nil
    end
    log_created_at { rand(1..14).days.ago }

    before :create do |instance|
      PaperTrail.whodunnit = rand(1..10).to_s
      instance.crash_log = File.new("#{Rails.root}/spec/fixtures/log_files/android_log.txt")
    end

    after :create do |instance, evaluator|
      PaperTrail.whodunnit = nil
      bool = [true, false].sample
      if bool
        project = Project.find_by_id(evaluator.project_id)
        create(:demo_issue, project_id: project.id, file: instance.crash_log,
                            main_user_id: project.user_id, statuses: evaluator.statuses,
                            log_file_id: instance.id, crash_id: instance.crash_id,
                            issue_type: 'crash')
      end
    end
  end

  factory :demo_plan, class: TestPlan do
    title { Faker::Book.title }
    description { Faker::Lorem.sentence }
    created_by { rand(1..10) }

    before :create do |instance|
      PaperTrail.whodunnit = instance.created_by.to_s
    end
    after :create do |instance|
      PaperTrail.whodunnit = nil
      2.times { create(:demo_module, test_plan_id: instance.id) }
    end
  end

  factory :demo_module, class: TestModule do
    title { Faker::Book.title }
    created_by { rand(1..10) }

    after :create do |instance|
      2.times { create(:demo_case, module_id: instance.id, test_plan_id: instance.test_plan_id) }
      create(:demo_sub_module, parent_id: instance.id, test_plan_id: instance.test_plan_id)
    end
  end

  factory :demo_sub_module, class: TestModule do
    title { Faker::Book.title }
    created_by { rand(1..10) }

    after :create do |instance|
      create(:demo_case, module_id: instance.id, test_plan_id: instance.test_plan_id)
    end
  end

  factory :demo_case, class: TestCase do
    title { Faker::Book.title }
    created_by { rand(1..10) }
    case_type { TestCase.case_type.values.sample }
    steps { Faker::Lorem.sentence }
    pre_steps { Faker::Lorem.sentence }
    expected_result { Faker::Lorem.sentence }
    created_at { rand(1..14).days.ago }

    before :create do |instance|
      PaperTrail.whodunnit = instance.created_by.to_s
    end
    after :create do |instance|
      PaperTrail.whodunnit = nil
    end
  end

  factory :demo_run, class: TestRun do
    assigner_id { rand(1..10) }
    reporter_id { rand(1..10) }
    run_status 'active'
    title { Faker::Book.title }

    before :create do |instance|
      PaperTrail.whodunnit = instance.reporter_id.to_s
    end
    after :create do |instance|
      PaperTrail.whodunnit = nil
      instance.test_cases_relation.pluck(:id).each do |case_id|
        create(:demo_result, test_run_id: instance.id, test_case_id: case_id,
                             passed_by: instance.assigner_id)
      end
    end
  end

  factory :demo_result, class: TestRunResult do
    status { [0, 1, 2, 4].sample }
  end

  factory :demo_issue, parent: :issue do
    transient do
      main_user_id nil
      statuses nil
      file nil
    end
    reporter_id { (1..10).to_a.push(main_user_id).sample }
    assigner_id { (1..10).to_a.push(main_user_id).sample }
    status_id { statuses.sample }
    priority { Issue.priority.values.sample }
    issue_type { Issue.issue_type.values.sample }
    created_at { rand(1..30).days.ago }

    before :create do |instance, evaluator|
      PaperTrail.whodunnit = instance.reporter_id.to_s
      unless evaluator.file.nil?
        instance.attachments.new(file: evaluator.file)
      end
    end

    after :create do |instance|
      rand(1..2).times { create(:demo_time, issue_id: instance.id, user_id: instance.reporter_id) }
      PaperTrail.whodunnit = nil
    end
  end

  factory :demo_time, class: TimeManagement do
    spent_time { (Time.at(0) + rand(1..8).hours).to_datetime }
    comment { Faker::Lorem.sentence }
  end
end
