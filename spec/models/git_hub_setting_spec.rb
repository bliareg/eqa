require 'rails_helper'

RSpec.describe GitHubSetting, type: :model do
  before :all do
    user = create(:user)
    org = create(:organization)
    @project = create(:project, owner: user, organization: org)
  end

  it 'factory is valid' do
    expect(build(:git_hub_setting, project_id: @project.id).valid?).to be_truthy
  end

  describe 'validations' do
    it 'repository must be present' do
      expect(build(:git_hub_setting,
                   project_id: @project.id,
                   repository_url: '').valid?).to be_falsey
    end

    it 'repository_url must be full repository URL' do
      expect(build(:git_hub_setting,
                   project_id: @project.id,
                   repository_url: 'something invalid').valid?).to be_falsey
    end

    it 'repository_url invalid without protocol' do
      expect(build(:git_hub_setting,
                   project_id: @project.id,
                   repository_url: 'github.com/test-thinkmobile/testing').valid?).to be_falsey
    end

    it 'repository_url invalid without both account name and repo name' do
      expect(build(:git_hub_setting,
                   project_id: @project.id,
                   repository_url: 'https://github.com').valid?).to be_falsey
    end


    it 'access_token must be present' do
      expect(build(:git_hub_setting,
                   project_id: @project.id,
                   access_token: nil).valid?).to be_falsey
    end
  end

  describe 'helper' do
    before :all do
      @git_hub_setting = create(:git_hub_setting)
    end

    it 'must be correct data' do
      expect(@git_hub_setting.helper.base_url).to eq @git_hub_setting.base_url
      expect(@git_hub_setting.helper.repository_name).to eq @git_hub_setting.repository_name
      expect(@git_hub_setting.helper.access_token).to eq @git_hub_setting.access_token
    end
  end
end
