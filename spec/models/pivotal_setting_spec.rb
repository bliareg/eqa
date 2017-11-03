require 'rails_helper'

RSpec.describe PivotalSetting, type: :model do
  before :all do
    user = create(:user)
    org = create(:organization)
    @project = create(:project, owner: user, organization: org)
  end

  it 'factory is valid' do
    expect(build(:pivotal_setting,
                 project_id: @project.id).valid?).to be_truthy
  end

  describe 'validations' do
    it 'project_name must be present' do
      expect(build(:pivotal_setting,
                   project_id: @project.id, project_name: nil).valid?).to be_falsey
    end

    it 'api_token must be present' do
      expect(build(:pivotal_setting,
                   project_id: @project.id, api_token: nil).valid?).to be_falsey
    end
  end

  describe 'helper' do
    before :all do
      @pivotal_setting = create(:pivotal_setting)
    end

    it 'must be correct data' do
      expect(@pivotal_setting.helper.project_name).to eq @pivotal_setting.project_name
      expect(@pivotal_setting.helper.api_token).to eq @pivotal_setting.api_token
    end
  end
end
