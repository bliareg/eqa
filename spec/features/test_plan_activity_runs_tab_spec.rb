require 'rails_helper'
require_relative 'feature_helper'

WITHIN_SELECTOR = '.testRun-box-item > .testRun-box-item-info'.freeze
BUTTON_TEXT = 'Create Test Run'.freeze

feature 'Test Plan Activity' do
  context '"Test run" tab' do
    context 'test runs not available' do
      scenario 'no test run present at page' do
        @user = FactoryGirl.create(:user)
        login_as @user, scope: :user
        create_project_with_only_owner
        @proj_1.test_plans << TestPlan.new(created_by: @user.id,
                                           title: Faker::Hacker.adjective,
                                           description: Faker::Hacker.say_something_smart)

        visit project_test_runs_path(@proj_1.id)

        expect(page).not_to have_content 'Edit'
        expect(page).not_to have_content 'Delete'
        expect(page).not_to have_content 'Pass'
        expect(page).not_to have_content 'Block'
        expect(page).not_to have_content 'Untested'
        expect(page).not_to have_content 'Fail'
        expect(page.has_no_css?('.testRun-box-item')).to be_truthy
      end
    end

    context 'test runs available' do
      before :all do
        @user = FactoryGirl.create(:user)
        create_project_with_only_owner
        @proj_1.test_plans << TestPlan.new(created_by: @user.id,
                                           title: Faker::Hacker.adjective,
                                           description: Faker::Hacker.say_something_smart)

        Random.new.rand(1...3).times do |i|
          TestPlan.create(created_by: @user.id,
                          project_id: @proj_1.id,
                          title: Faker::Hacker.adjective,
                          description: Faker::Hacker.say_something_smart)
        end

        TestPlan.all.each do |test_plan|
          id = test_plan.id
          Random.new.rand(1...3).times do |j|

            test_module = TestModule.create(test_plan_id: id,
                                            created_by: @user.id,
                                            title: Faker::Company.buzzword,
                                            description: Faker::Company.catch_phrase)

            Random.new.rand(1...4).times do |k|
              TestCase.create(test_plan_id: test_plan.id,
                              module_id: test_module.id,
                              updated_by: @user.id,
                              title: Faker::Company.name,
                              selection: nil,
                              case_type: 0)
            end
          end
        end

        test_plan = TestPlan.first

        @test_run = TestRun.create(test_plan_id: test_plan.id,
                                   project_id: @proj_1.id,
                                   assigner_id: @user.id,
                                   title: Faker::Company.bs,
                                   description: Faker::Space.agency,
                                   test_run_results_attributes: [{ 'test_plan_id' => test_plan.id }])

        Notification.create(user_id: @user.id,
                            notificable_id: @proj_1.id,
                            notificable_type: "Project")

        Notification.add_test_run_notification(@proj_1.id, @test_run)
      end

      before :each do
        login_as @user, scope: :user
        visit project_test_runs_path(@proj_1.id)
      end

      feature 'test run example' do
        feature 'all test run elements present' do
          scenario '"Title" is present' do
            enable_text_in_selector?(@test_run.title)
          end

          scenario '"Assigned at" is present' do
            enable_text_in_selector?(@user.name)
          end

          scenario '"Edit" link is present' do
            enable_text_in_selector?('Edit')
          end

          scenario '"Delete" link is present' do
            enable_text_in_selector?('Delete')
          end

          scenario '"Pass" counter is present' do
            enable_text_in_selector?('0 Pass')
          end

          scenario '"Block" counter is present' do
            enable_text_in_selector?('0 Block')
          end

          scenario '"Untested" counter is present' do
            # кількість не вказував для швидкості - тест кількості окремо
            enable_text_in_selector?('Untested')
          end

          scenario '"Fail" counter is present' do
            enable_text_in_selector?('0 Fail')
          end

          scenario '"% diagram" counter is present' do
            enable_text_in_selector?('0%', '.progress-bar')
          end
        end

        feature 'counters show proper amount of cases' do
          before :each do
            values = [0, 1, 2, 4]
            TestRunResult.all.each do |result|
              result.update(status: values[Random.new.rand(4)])
              visit project_test_runs_path(@proj_1.id)
            end
          end

          scenario '"Pass" counter' do
            TestRun.all.each do |run|
              values = status_counters(1, TestRunResult::PASS, run)

              expect(values[:page]).to eq values[:calculations]
            end
          end
          scenario '"Block" counter' do
            TestRun.all.each do |run|
              values = status_counters(2, TestRunResult::BLOCK, run)

              expect(values[:page]).to eq values[:calculations]
            end
          end
          scenario '"Untested" counter' do
            TestRun.all.each do |run|
              values = status_counters(3, TestRunResult::UNTESTED, run)

              expect(values[:page]).to eq values[:calculations]
            end
          end
          scenario '"Fail" counter' do
            TestRun.all.each do |run|
              values = status_counters(4, TestRunResult::FAIL, run)

              expect(values[:page]).to eq values[:calculations]
            end
          end

          scenario '"% diagram" counter', js: true do
            TestRun.all.each do |run|
              xpath = "//a[text()='#{run.title}']/../../div[3]//span"
              page_value = find(:xpath, xpath).text.to_i
              all = run.test_run_results.count
              passed = run.test_run_results
                          .where(status: TestRunResult::PASS).count
              calculations = (passed * 100) / all

              expect(page_value).to eq calculations
            end
          end
        end

        feature 'link routes has proper routes' do
          scenario '"Title" - show test run popup'
          scenario '"Edit" - show test run edit popup'
          scenario '"Delete" - show test run delete popup'
        end
      end

      scenario 'all test runs are present at page' do
        TestPlan.all.each do |test_plan|
          test_run = TestRun.create(test_plan_id: test_plan.id,
                                    project_id: @proj_1.id,
                                    assigner_id: @user.id,
                                    title: Faker::Company.bs,
                                    description: Faker::Space.agency,
                                    test_run_results_attributes: [{ 'test_plan_id' => test_plan.id }])

          Notification.create(user_id: @user.id,
                              notificable_id: @proj_1.id,
                              notificable_type: "Project")

          Notification.add_test_run_notification(@proj_1.id, test_run)
        end

        visit project_test_runs_path(@proj_1.id)

        TestRun.all.select(:title).each do |test_run|
          enable_text_in_selector?(test_run.title, '.tab-pane-content')
        end
      end

      fscenario 'new, active and finished runs placed in right section' do
        #####################################################################
        test_runs = Hash.new([])
        TestRun.all.each do |run|
          is_new = run.test_run_results.all? do |run_result|
            run_result.status == TestRunResult::UNTESTED
          end

          is_finished = run.test_run_results.all? do |run_result|
            run_result.status != TestRunResult::UNTESTED
          end

          if is_new
            (test_runs[:new]) << run
          elsif is_finished
            (test_runs[:finished]) << run
          else
            (test_runs[:active]) << run
          end
        end

        new_runs_xpath = "//h2[text()='New test runs']/.."
        active_runs_xpath = "//h2[text()='Active test runs']/.."
        finished_runs_xpath = "//h2[text()='Finished test runs']/.."

        within(:xpath, new_runs_xpath) do
          test_runs[:new].each do |run|
            expect(have_content(run.title)).to be_truthy
          end
        end
        within(:xpath, active_runs_xpath) do
          test_runs[:active].each do |run|
            expect(have_content(run.title)).to be_truthy
          end
        end
        within(:xpath, finished_runs_xpath) do
          test_runs[:finished].each do |run|
            expect(have_content(run.title)).to be_truthy
          end
        end
      end
    end

    context 'test plan independent functions' do

      before :each do
      end

      scenario '"Test run" tab is active', js: true do
        @user = FactoryGirl.create(:user)
        login_as @user, scope: :user
        create_project_with_only_owner
        visit project_test_runs_path(@proj_1.id)

        xpath = "//a[text()='Test run']"
        within('.nav-tabs') do
          element_classes = find(:xpath, xpath)[:class].split
          expect(element_classes.any? { |clas| clas == 'active' }).to be_truthy
        end
      end

      scenario 'static content shown properly' do
        @user = FactoryGirl.create(:user)
        login_as @user, scope: :user
        create_project_with_only_owner
        visit project_test_runs_path(@proj_1.id)

        expect(page).to have_content 'New test runs'
        expect(page).to have_content 'Active test runs'
        expect(page).to have_content 'Finished test runs'
      end

      feature '"Create Test Run" button is shown according to authorization rules' do
        before :each do
          @user = FactoryGirl.create(:user)
          create_project_with_only_owner
        end

        scenario 'is shown for owner' do
          login_as @user, scope: :user
          visit project_test_runs_path(@proj_1.id)

          within('.tab-pane-content') do
            expect(has_content?(BUTTON_TEXT)).to be_truthy
          end
        end
        scenario 'is shown for admin' do
          add_another_user_to_organization_and_project_and_login(:role_admin)
          visit project_test_runs_path(@proj_1.id)

          within('.tab-pane-content') do
            expect(has_content?(BUTTON_TEXT)).to be_truthy
          end
        end

        scenario 'isn"t shown for developer' do
          add_another_user_to_organization_and_project_and_login(:role_developer)
          visit project_test_runs_path(@proj_1.id)

          within('.tab-pane-content') do
            expect(has_content?(BUTTON_TEXT)).to be_falsey
          end
        end

        scenario 'is shown for tester' do
          add_another_user_to_organization_and_project_and_login(:role_tester)
          visit project_test_runs_path(@proj_1.id)

          within('.tab-pane-content') do
            expect(has_content?(BUTTON_TEXT)).to be_truthy
          end
        end
        scenario 'isn"t shown for viewer' do
          add_another_user_to_organization_and_project_and_login(:role_viewer)
          visit project_test_runs_path(@proj_1.id)

          within('.tab-pane-content') do
            expect(has_content?(BUTTON_TEXT)).to be_falsey
          end
        end
        scenario 'is shown for project manager' do
          add_another_user_to_organization_and_project_and_login(:role_project_manager)
          visit project_test_runs_path(@proj_1.id)

          within('.tab-pane-content') do
            expect(has_content?(BUTTON_TEXT)).to be_truthy
          end
        end
      end
    end
  end
end

def add_another_user_to_organization_and_project_and_login(role)
  user_1 = FactoryGirl.create(:user)
  org_1 = Organization.find_by_title('Organization_1')
  org_1.roles << build(role, user_id: user_1.id)
  @proj_1.roles << build(role,
                         user_id: user_1.id,
                         organization_id: org_1.id)

  login_as user_1, scope: :user
end

def enable_text_in_selector?(text, selector = WITHIN_SELECTOR)
  within(selector) do
    expect(page).to have_content text
  end
end

def status_counters(xpath_index, status_value, test_run)
  xpath = "//a[text()='#{test_run.title}']/..//ul/li[#{xpath_index}]"
  { page: find(:xpath, xpath).text.to_i,
    calculations: test_run.test_run_results.where(status: status_value).count }
end
