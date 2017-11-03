require 'rails_helper'

RSpec.describe SynchronizationsController, type: :controller do
  before :all do
    setup_statuses
    @user = create(:user)
    @organization = create(:organization)
    Role.create(organization_id: @organization.id,
                user_id: @user.id,
                project_id: nil,
                role: 0)
    @project = create(:project, organization: @organization, owner: @user)
  end

  describe 'POST issue_synchroniztions' do
    context 'Git Lab' do
      include_examples :synchronization_issues_example, 'git_lab_setting'
    end

    context 'Git Hub' do
      include_examples :synchronization_issues_example, 'git_hub_setting'
    end

    context 'You Track' do
      include_examples :synchronization_issues_example, 'you_track_setting'
    end

    context 'Jira' do
      include_examples :synchronization_issues_example, 'jira_setting'
    end

    context 'Redmine' do
      include_examples :synchronization_issues_example, 'redmine_setting'
    end

    context 'Pivotal' do
      include_examples :synchronization_issues_example, 'pivotal_setting'
    end

    context 'Trello' do
      include_examples :synchronization_issues_example, 'trello_setting'
    end
  end

  describe 'GET choose integration' do
    it 'must be complete' do
      sign_in @user
      get :index, project_id: @project.id, plugin_name: :stub
      expect(response.status).to eq 200
    end
  end

  describe 'GET new integration' do
    it 'must be complete' do
      sign_in @user
      xhr :get, :new, params: {
        project_id: @project.id,
        plugin_name: 'git_lab_setting'
      }
      expect(response.status).to eq 200
    end
  end

  describe 'POST create integration' do
    describe 'Git Lab' do
      it 'must be create' do
        sign_in @user
        new_project = create(:project, organization: @organization,
                                       owner: @user)
        git_lab_setting = build(:git_lab_setting)
        post :create, params: {
          project_id: new_project.id,
          plugin_name: 'git_lab_setting',
          git_lab_setting: git_lab_setting.attributes,
          format: 'js'
        }
        expect(response.status).to eq 200
        expect(Project.find(new_project.id)
                      .git_lab_settings.first
                      .access_token).to eq git_lab_setting.access_token
      end
    end
  end
end
