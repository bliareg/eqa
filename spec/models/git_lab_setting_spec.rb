require 'rails_helper'

RSpec.describe GitLabSetting, type: :model do
  before :all do
    user = create(:user)
    org = create(:organization)
    @project = create(:project, owner: user, organization: org)
  end

  it 'factory is valid' do
    expect(build(:git_lab_setting,
           project_id: @project.id).valid?).to be_truthy
  end

  describe 'validations' do
    it 'project url must be present' do
      expect(build(:git_lab_setting,
                   project_id: @project.id,
                   project_url: '').valid?).to be_falsey
    end

    it 'project url must be correct format' do
      expect(build(:git_lab_setting,
                   project_id: @project.id,
                   project_url: 'something invalid').valid?).to be_falsey
    end

    it 'access token must be present' do
      expect(build(:git_lab_setting,
                   project_id: @project.id,
                   access_token: nil).valid?).to be_falsey
    end
  end

  describe 'helper' do
    before :all do
      @git_lab_setting = create(:git_lab_setting)
    end

    it 'must be correct data' do
      expect(@git_lab_setting.helper.base_url).to eq @git_lab_setting.base_url
      expect(@git_lab_setting.helper.access_token).to eq @git_lab_setting.access_token
      expect(@git_lab_setting.helper.service_project_id).to eq @git_lab_setting.service_project_id
    end
  end
end
