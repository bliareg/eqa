require 'rails_helper'

RSpec.describe JiraSetting, type: :model do
  before :all do
    user = create(:user)
    org = create(:organization)
    @project = create(:project, owner: user, organization: org)
  end

  it 'factory is valid' do
    expect(build(:jira_setting,
                 project_id: @project.id).valid?).to be_truthy
  end

  describe 'validations' do
    it 'base url must be present' do
      expect(build(:jira_setting,
                   project_id: @project.id, base_url: '').valid?).to be_falsey
    end

    it 'base url must be correct format' do
      expect(build(:jira_setting,
                   project_id: @project.id, base_url: 'something invalid').valid?).to be_falsey
    end

    it 'username must be present' do
      expect(build(:jira_setting,
                   project_id: @project.id, username: nil).valid?).to be_falsey
    end

    it 'password must be present' do
      expect(build(:jira_setting,
                   project_id: @project.id, password: nil).valid?).to be_falsey
    end

    it 'project key must be present' do
      expect(build(:jira_setting,
                   project_id: @project.id, project_key: nil).valid?).to be_falsey
    end

    it 'board_name must be present' do
      expect(build(:jira_setting,
                   project_id: @project.id, board_name: nil).valid?).to be_falsey
    end
  end

  describe 'helper' do
    before :all do
      @jira_setting = create(:jira_setting)
    end

    it 'must be correct data' do
      expect(@jira_setting.helper.site).to eq @jira_setting.site
      expect(@jira_setting.helper.context_path).to eq @jira_setting.context_path
      expect(@jira_setting.helper.project_key).to eq @jira_setting.project_key
      expect(@jira_setting.helper.board_name).to eq @jira_setting.board_name
    end
  end
end
