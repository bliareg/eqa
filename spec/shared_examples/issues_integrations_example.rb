require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

RSpec.shared_examples :issues_integrations_example do |setting_name|
  before :all do
    @setting = create(setting_name.to_sym, project: @project)
    @issue = create(:issue, project_id: @project.id, reporter_id: @user.id)
  end

  context 'after create' do
    it 'plugin must be present' do
      expect(@issue.plugins.find_by(name: setting_name)).to be_truthy
    end

    it 'issue must be create in plugin' do
      issue = @issue.service_object(@setting)
      expect(issue[:summary]).to eq @issue.summary
      expect(issue[:description]).to eq @issue.description
    end
  end

  context 'after_update' do
    it 'issue title and description must be update in plugin' do
      @issue.update(summary: "Updated #{@issue.summary}",
                    description: "Updated #{@issue.description}",
                    updater_id: @user.id)
      issue = @issue.service_object(@setting)
      expect(issue[:summary]).to eq @issue.summary
      expect(issue[:description]).to eq @issue.description
    end
  end

  context 'after_destroy' do
    before :all do
      @service_id = @issue.service_id(@setting)
      @issue.destroy
    end

    it 'all plugins must be destroyed' do
      expect(@issue.plugins.size).to eq 0
    end

    it 'service issue must be destroyed' do
      deleted_issue_request = @setting.helper.show_issue(@service_id)
      if setting_name == 'git_hub_setting'
        expect(deleted_issue_request[:body][:status_id]).to eq Status::DEFAULT_STATUSES[:closed][:id]
      else
        expect(deleted_issue_request[:complete]).to eq false
      end
    end
  end
end
