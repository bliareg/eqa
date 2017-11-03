require 'rails_helper'

RSpec.describe RedmineSetting, type: :model do

  before :all do
    @project = create(:project,
                      owner: create(:user),
                      organization: create(:organization))
  end

  it 'factory is valid' do
    expect(build(:redmine_setting,
                 project_id: @project.id).valid?).to be_truthy
  end

  describe 'validations' do
    it 'base url must be present' do
      expect(build(:redmine_setting,
                   project_id: @project.id, base_url: '').valid?).to be_falsey
    end

    it 'base url must be correct format' do
      expect(build(:redmine_setting,
                   project_id: @project.id, base_url: 'something invalid').valid?).to be_falsey
    end

    it 'tracker_name must be present' do
      expect(build(:redmine_setting,
                   project_id: @project.id, tracker_name: nil).valid?).to be_falsey
    end

    it 'project_name must be present' do
      expect(build(:redmine_setting,
                   project_id: @project.id, project_name: nil).valid?).to be_falsey
    end

    it 'api key must be present' do
      expect(build(:redmine_setting,
                   project_id: @project.id, api_key: nil).valid?).to be_falsey
    end
  end

  describe 'helper' do
    before :all do
      @redmine_setting = create(:redmine_setting)
    end

    it 'must be correct data' do
      expect(@redmine_setting.helper.base_url).to eq @redmine_setting.base_url
      expect(@redmine_setting.helper.project_name).to eq @redmine_setting.project_name
      expect(@redmine_setting.helper.tracker_name).to eq @redmine_setting.tracker_name
      expect(@redmine_setting.helper.api_key).to eq @redmine_setting.api_key
    end
  end
end
