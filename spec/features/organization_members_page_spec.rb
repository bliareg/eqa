require 'rails_helper'
require_relative 'feature_helper'

feature 'Organization members page' do
  background do
    @user = FactoryGirl.create(:user)
  end

  context 'member has projects' do
    background do
      @member_with_projects = create(:user)

      @organization = create(:organization)
      create(:project, organization: @organization,
                       owner: @member_with_projects)
      create(:project, organization: @organization,
                       owner: @user)
      @organization.roles << build(:role_owner, user_id: @member_with_projects.id)
      @organization.roles << build(:role_admin, user_id: @user.id)
      login_as @member_with_projects, scope: :user
      create_test_data_for_member
      @member_without_projects = FactoryGirl.create(:user)

      Role.create(user_id: @member_without_projects.id, role: 2,
                  organization_id: Organization.first.id)
      Role.create(user_id: @member_without_projects.id, role: 5,
                  organization_id: Organization.first.id,
                  project_id: @proj_1.id)
      Role.create(user_id: @member_without_projects.id, role: 4,
                  organization_id: Organization.first.id,
                  project_id: @proj_2.id)
    end

    scenario 'has static content' do
      visit organization_profile_members_path(@organization)

      check_logged_header
      check_member_static_content
      check_members_title_and_button
    end

    scenario 'has dynamic content' do
      visit organization_path(@organization)
      check_logged_header
      check_organization_info(@organization)

      visit organization_profile_members_path(@organization)

      expect(page).to have_content(I18n.t('project_single'))

      @member_with_projects.roles.where(organization: @organization.id) do |role|
        expect(page).to have_content(role.organization.title)
        expect(page).to have_content(role.role.capitalize)
      end
    end
  end

  context 'member has no projects' do
    background do
      @member_with_projects = FactoryGirl.create(:user)
      @member_without_projects = FactoryGirl.create(:user)
      login_as @member_without_projects, scope: :user
      create_test_data_for_member
      @organization = create(:organization)
      @organization.roles << build(:role_owner, user_id: @member_without_projects.id)
      Role.create(user_id: @member_without_projects.id, role: 2,
                  organization_id: Organization.first.id)
    end

    scenario 'has static content' do
      visit organization_profile_members_path(@organization)

      check_logged_header
      check_members_title_and_button
      check_member_static_content
    end

    scenario 'doesn"t have dynamic content' do
      @member_with_projects.destroy
      visit organization_path(@organization)
      check_organization_info(@organization)

      visit organization_profile_members_path(@organization)

      check_logged_header
      within('#dashboard') do
        expect(page).to_not have_content(I18n.t('project_role'))
        expect(page).to_not have_content(I18n.t('distribution_groups'))
      end
    end
  end
end
