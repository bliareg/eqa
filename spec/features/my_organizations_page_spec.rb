require 'rails_helper'
require_relative 'feature_helper'

feature 'My Organizations header page', type: :feature do
  background do
    @user = FactoryGirl.create(:user)
    login_as @user, scope: :user
    visit organizations_path
  end

  scenario 'main header is shown properly' do
    visit edit_user_path
    check_logged_header
  end

  scenario 'required static text present' do
    # profile info
    expect(page).to have_content 'Organizations'
    expect(page).to have_content 'Projects'
    expect(page).to have_content 'Employees'
    expect(page).to have_content 'My Organizations'
    expect(page).to have_content 'Create new organization'
    # left menu
    expect(page).to have_content 'Personal Information'
    expect(page).to have_content 'Change password'
    expect(page).to have_content 'My organizations'
    expect(page).to have_content 'Notifications'
  end

  it '"Registration date" label date format'
  it '"Last visit date" label date format'

  feature 'with test data', type: :feature do
    background do
      create_test_data
    end

    scenario 'dynamic text is shown properly' do
      expect(page).to have_content @user.name

      active_organizations = @user.organizations
                                  .select { |organization| organization.owner != @user }
      visit organizations_path
      [@owned_organizations, active_organizations].each do |group|
        within '#content' do
          group.each { |organization| check_organization_raw(organization) }
        end
      end
    end

    scenario 'organization info is shown properly for owner' do
      expect(page).to have_content @user.name

      visit organizations_path

      [@owned_organizations].each do |group|
        within '#content' do
          group.each { |organization| check_organization_raw(organization) }
        end
      end

      link_name = @owned_organizations.first.title
      click_link link_name

      expect(page).to have_content 'You are Owner'
    end

    scenario 'other organizations info is shown properly'

    scenario 'organization projects info is shown properly' do
      visit organization_path(@org_1)

      check_organization_info(@owned_organizations.first)
    end
  end

  scenario 'Plans & Billings is shown properly'
end
