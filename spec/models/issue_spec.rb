require 'rails_helper'

RSpec.describe Issue, type: :model do
  it 'factory is valid' do
    expect(build(:issue).valid?).to be_truthy
  end

  describe 'validations' do
    it 'summary must be present' do
      expect(build(:issue, summary: nil,
                           description: 'something').valid?).to be_falsey
    end
  end

  describe 'plugin' do
    before :all do
      @user = create(:user)
      org = create(:organization)
      @project = create(:project, owner: @user, organization: org)
      setup_statuses
    end

    context 'Git Lab' do
      include_examples :issues_integrations_example, 'git_lab_setting'
    end
    context 'You Track' do
      include_examples :issues_integrations_example, 'you_track_setting'
    end
    context 'Git Hub' do
      include_examples :issues_integrations_example, 'git_hub_setting'
    end
    context 'Jira' do
      include_examples :issues_integrations_example, 'jira_setting'
    end
    context 'Redmine' do
      include_examples :issues_integrations_example, 'redmine_setting'
    end
    context 'Pivotal' do
      include_examples :issues_integrations_example, 'pivotal_setting'
    end
  end
end
