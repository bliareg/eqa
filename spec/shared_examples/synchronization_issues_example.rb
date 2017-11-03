require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

RSpec.shared_examples :synchronization_issues_example do |setting_name|
  before :all do
    @setting = create(setting_name.to_sym, project: @project)
    @helper = @setting.helper
    @params = [{ name: @setting.name, id: @setting.id }]
  end

  before :each do
    sign_in @user
  end

  it 'create uniq issue from site' do
    plugin_issue = @helper.create_issue(build(:issue).attributes)

    SyncIssueWorker.perform_async(@params, @project.id, @user.id)
    created_issue = Issue.joins(:plugins)
                         .find_by(plugins: { setting_id: @setting.id,
                                             setting_type: @setting.class.name,
                                             service_id: plugin_issue[:body][:id] })
    expect(created_issue.present?).to eq true
  end

  it 'create uniq issue from plugin' do
    issue = create(:issue, skip_plugins_synchronize: true,
                           project_id: @project.id)
    SyncIssueWorker.perform_async(@params, @project.id, @user.id)

    issue.reload
    created_issue = @helper.show_issue(issue.service_id(@setting))
    expect(created_issue[:body][:summary]).to eq issue.summary
    expect(created_issue[:body][:description]).to eq issue.description
  end

  it 'destroy deleted issue in plugins' do
    sign_in @user
    issue = create(:issue, project_id: @project.id)
    @helper.destroy_issue(issue.service_id(@setting))
    expect(issue.reload.present?).to eq true
    SyncIssueWorker.perform_async(@params, @project.id, @user.id)
    if setting_name == 'git_hub_setting'
      expect(Issue.find_by_id(issue.id).status_id).to eq Status::DEFAULT_STATUSES[:closed][:id]
    else
      expect(Issue.find_by_id(issue.id)).to be_falsey
    end
  end

  it 'update changed issue in plugins' do
    sign_in @user
    issue = create(:issue, project_id: @project.id)
    updated_issue = build(:issue)
    @helper.update_issue(updated_issue.attributes, issue.service_id(@setting))

    SyncIssueWorker.perform_async(@params, @project.id, @user.id)
    issue.reload
    expect(issue.summary).to eq updated_issue.summary
    expect(issue.description).to eq updated_issue.description
  end

  it 'destroy_all issue on plugin' do
    sign_in @user
    @setting.update(enable_synchronization: true,
                    synchronization_type: :all)
    SyncIssueWorker.perform_async(@params, @project.id, @user.id)

    Issue.destroy_all
    expect(@helper.all_service_issues.size).to eq 0
  end

  describe 'synchronization setting' do
    before :all do
      @setting.update(enable_synchronization: false)
      @helper = @setting.helper
    end
    it 'create service issue without issue plugin if disable sync' do
      sign_in @user
      issue = create(:issue, project_id: @project.id)
      expect(issue.plugins.length).to eq 0

      count_issues_before = @helper.all_service_issues.size

      SyncIssueWorker.perform_async(@params, @project.id, @user.id)

      count_issues_after = @helper.all_service_issues.size
      issue.reload
      expect(issue.plugins.length).to eq 1
      expect(count_issues_after).to eq count_issues_before + 1
    end

    it 'doesn`t create issue on plugin when synch type only pushed' do
      sign_in @user

      @setting.update(synchronization_type: :only_pushed)
      issue = create(:issue, project_id: @project.id)

      expect(issue.plugins.length).to eq 0
      count_issues_before = @helper.all_service_issues.size

      SyncIssueWorker.perform_async(@params, @project.id, @user.id)

      count_issues_after = @helper.all_service_issues.size
      issue.reload
      expect(issue.plugins.length).to eq 0
      expect(count_issues_before).to eq count_issues_after
    end
  end
end
