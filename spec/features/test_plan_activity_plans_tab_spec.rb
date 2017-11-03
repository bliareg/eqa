require 'rails_helper'
require_relative 'feature_helper'

NON_ACTIVE_CLASS    = '.btn-nonActive'.freeze
ADD_MODULE_SELECTOR = '.btn-group > a:nth-child(1)'.freeze
ADD_CASE_SELECTOR   = '.btn-group > a:nth-child(2)'.freeze
EXPORT_SELECTOR     = '.icon-block > .icon-btn.export'.freeze
IMPORT_SELECTOR     = '.icon-block > .open_popup.icon-btn.import'.freeze
COLUMNS_SELECTOR    = '.icon-block > .open_popup.icon-btn.columns'.freeze
PLANS_WIDE_TOGGLE   = '.plans-toggle'.freeze

feature 'Test Plan Activity' do
  context '"Test plans" tab' do
    context 'test plans not available' do
      before :each do
        @user = FactoryGirl.create(:user)
        login_as @user, scope: :user
        create_project_with_only_owner
        visit project_test_plans_path(@proj_1.id)
      end

      scenario '"Add module" button is non active' do
        selector = ADD_MODULE_SELECTOR + NON_ACTIVE_CLASS

        expect(has_css?(selector)).to be_truthy
      end

      scenario '"Add case" button is non active' do
        selector = ADD_CASE_SELECTOR + NON_ACTIVE_CLASS

        expect(has_css?(selector)).to be_truthy
      end

      scenario '"Export" button is non active' do
        selector = EXPORT_SELECTOR + NON_ACTIVE_CLASS

        expect(has_css?(selector)).to be_truthy
      end

      scenario '"Import" button is non active' do
        selector = IMPORT_SELECTOR + NON_ACTIVE_CLASS

        expect(has_css?(selector)).to be_truthy
      end

      scenario '"Columns" button is non active' do
        selector = COLUMNS_SELECTOR + NON_ACTIVE_CLASS

        expect(has_css?(selector)).to be_truthy
      end

      scenario 'Shows proper amount of modules and cases at right panel header', js: true do
        page.find(PLANS_WIDE_TOGGLE).click

        expect(page).to have_content 'Contains 0 modules and 0 cases'
      end
    end

    context 'test plans available' do
      before :each do
        @user = FactoryGirl.create(:user)
        login_as @user, scope: :user
        create_project_with_only_owner
        @proj_1.test_plans << TestPlan.new(created_by: @user.id,
                                           title: 'Some test plan',
                                           description: 'some description')
        visit project_test_plans_path(@proj_1.id)
      end

      scenario '"Add module" button is active' do
        anti_selector = ADD_MODULE_SELECTOR + NON_ACTIVE_CLASS
        element = find(ADD_MODULE_SELECTOR)

        expect(element.matches_selector?(anti_selector)).to be_falsey
      end

      scenario '"Add case" button is active' do
        anti_selector = ADD_CASE_SELECTOR + NON_ACTIVE_CLASS
        element = find(ADD_CASE_SELECTOR)

        expect(element.matches_selector?(anti_selector)).to be_falsey
      end

      scenario '"Export" button is active' do
        anti_selector = EXPORT_SELECTOR + NON_ACTIVE_CLASS
        element = find(EXPORT_SELECTOR)

        expect(element.matches_selector?(anti_selector)).to be_falsey
      end

      scenario '"Import" button is active' do
        anti_selector = IMPORT_SELECTOR + NON_ACTIVE_CLASS
        element = find(IMPORT_SELECTOR)

        expect(element.matches_selector?(anti_selector)).to be_falsey
      end

      scenario '"Columns" button is active' do
        anti_selector = COLUMNS_SELECTOR + NON_ACTIVE_CLASS
        element = find(COLUMNS_SELECTOR)

        expect(element.matches_selector?(anti_selector)).to be_falsey
      end

      scenario 'Shows proper amount of modules and cases at right panel header', js: true do
        Random.new.rand(1...4).times do |i|
          TestPlan.create(created_by: @user.id,
                          project_id: @proj_1.id,
                          title: "Some test plan #{i}",
                          description: "description #{i}")
        end

        TestPlan.all.each do |test_plan|
          id = test_plan.id
          Random.new.rand(1...4).times do |j|
            test_module = TestModule.create(test_plan_id: id,
                                            created_by: @user.id,
                                            title: "Module #{id} #{j}",
                                            description: "description #{id} #{j}")

            Random.new.rand(1...4).times do |k|
              TestCase.create(test_plan_id: test_plan.id,
                              module_id: test_module.id,
                              updated_by: @user.id,
                              title: "Test case  #{id} #{j} #{k}",
                              selection: nil,
                              case_type: 0)
            end
          end
        end

        visit project_test_plans_path(@proj_1.id)
        page.find(PLANS_WIDE_TOGGLE).click

        @current_plan = TestPlan.first
        modules = @current_plan.test_modules.count
        cases = @current_plan.test_cases.count

        within('.tab-pane-content') do
          expect(page).to have_content "Contains #{modules} modules and #{cases} cases"
        end
      end

      scenario 'First test plan is higlighted by default', js: true do
        Capybara.wait_on_first_by_default
        @proj_1.test_plans << TestPlan.new(created_by: @user.id,
                                           title: 'Second plan',
                                           description: 'some description')

        visit project_test_plans_path(@proj_1.id)
        selector = 'div.plans.plans-open .plans-info-item'
        element = first(selector)

        expect(element.matches_css?(selector + '.active')).to be_truthy
      end

      scenario 'Click on other test plan move highlight to clicked plan', js: true do
        Capybara.wait_on_first_by_default
        @proj_1.test_plans << TestPlan.new(created_by: @user.id,
                                           title: 'Second plan',
                                           description: 'some description')

        visit project_test_plans_path(@proj_1.id)
        element = all('div', text: 'Second plan')[1]
        element.click

        selector = 'div.plans.plans-open .plans-info-item'
        active_element = first(selector + '.active')

        expect(element = active_element).to be_truthy
      end
    end

    context 'test plan independent functions' do
      before :each do
        @user = FactoryGirl.create(:user)
        login_as @user, scope: :user
        create_project_with_only_owner
        @proj_1.test_plans << TestPlan.new(created_by: @user.id,
                                           title: 'Some test plan',
                                           description: 'some description')
        visit project_test_plans_path(@proj_1.id)
      end

      scenario '"Test plans" tab is active', js: true do
        selector = 'a.btn.btn-gray.link_profile_menu.expanded.active'
        within('.nav-tabs > li:nth-child(2)') do
          expect(page.has_css?(selector)).to be_truthy
        end
      end

      scenario '"New test plan" button is present on the page', js: true do
        expect(page).to have_content 'New test plan'
      end

      scenario 'test plans are expanded by default', js: true do
        expect(page.has_css?('.tab-pane-content .tab-pane-content-info div.plans.plans-open')).to be_truthy

        expect(page.has_css?('.tab-pane-content-header > .contains.contains-close',
                             visible: false)).to be_truthy
        expect(page.has_css?('.plans .open-addTestPlan.open-addTestPlan-block')).to be_truthy

        expect(page.has_css?('div.plans.plans-open a.plans-item-inner-left.grow')).to be_truthy

        expect(page.has_css?('.main-content-info a.link_profile_menu.expanded')).to be_truthy

        expect(page.has_css?('.plans-toggle.open')).to be_truthy

        expect(page.has_css?('.plans-toggle span.fa-caret-left')).to be_truthy
      end

      fscenario 'click on ".plans-toggle" will narrow test plans', js: true do
        Capybara.default_max_wait_time= 30

        page.find('.fa-caret-left')
        page.find('.plans-toggle.open').click

        element = find('.tab-pane-content .tab-pane-content-info .plans')
        expect(element.not_matches_css?('.plans.plans-open')).to be_truthy

        expect(page.has_css?('.tab-pane-content-header > div.contains')).to be_truthy
        expect(page.has_no_css?('.tab-pane-content-header > .contains.contains-close')).to be_truthy

        expect(page.has_css?('.plans .open-addTestPlan', visible: false)).to be_truthy

        expect(page.has_css?('div.plans a.plans-item-inner-left')).to be_truthy
        expect(page.has_no_css?('div.plans.plans-open a.plans-item-inner-left.grow')).to be_truthy

        expect(page.has_css?('a.link_profile_menu')).to be_truthy
        expect(page.has_no_css?('a.link_profile_menu.expanded')).to be_truthy

        expect(page.has_css?('.plans-toggle')).to be_truthy
        expect(page.has_no_css?('.plans-toggle.open')).to be_truthy
        element_classes = find('.plans-toggle span.fa')[:class].split

        expect(element_classes.any? { |clas| clas == 'fa-caret-right' }).to be_truthy
        expect(element_classes.any? { |clas| clas == 'fa-caret-left' }).to be_falsey
      end

      xscenario 'click on "Columns" button will show popup', js: true do
        # Capybara.default_max_wait_time= 20

        # find('.logo_title > a').click

        # byebug
        # element = all(:xpath, '//a[@class="columns"]').first.click

        element = find('.icon-block .open_popup.icon-btn.columns')
        element.trigger('click')
        # sleep 20
        page.save_screenshot

        expect(page).to have_content 'Project History'
      end

      it 'кнопки додавання плану / тесту / кейса показуються в залежносты від ролей ?'
    end
  end
end
