require 'rails_helper'

RSpec.describe TrelloSetting, type: :model do

  before :all do
    Status::DEFAULT_STATUSES.each_value do |params_status|
      Status.create(name: params_status[:name])
    end
    Status.first.update_attribute(:id, 1)
    @project = create(:project,
                      owner: create(:user),
                      organization: create(:organization))
  end

  it 'factory is valid' do
    expect(build(:trello_setting,
                 project_id: @project.id).valid?).to be_truthy
  end

  describe 'validations' do
    it 'board_name must be present' do
      expect(build(:trello_setting,
                   project_id: @project.id, board_name: nil).valid?).to be_falsey
    end

    it 'api key must be present' do
      expect(build(:trello_setting,
                   project_id: @project.id, api_key: nil).valid?).to be_falsey
    end

    it 'member_token must be present' do
      expect(build(:trello_setting,
                   project_id: @project.id, member_token: nil).valid?).to be_falsey
    end
  end

  describe 'helper' do
    before :all do
      @trello_setting = create(:trello_setting,
                               project: @project)
    end

    it 'must be correct data' do
      expect(@trello_setting.helper.board_name).to eq @trello_setting.board_name
      expect(@trello_setting.helper.api_key).to eq @trello_setting.api_key
      expect(@trello_setting.helper.member_token).to eq @trello_setting.member_token
    end
  end
end
