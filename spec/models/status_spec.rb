require 'rails_helper'

RSpec.describe Status, type: :model do

  before(:each) do
    @status = create(:status)
  end

  it 'factory is valid' do
    expect(@status.valid?).to be_truthy
  end

  it 'default statuses are created if they are absent' do
    expect(Status.count).to eq 8
  end

  it '#default? returns true if 1 <= status.id <= 7' do
    (1..7).each { |id| expect(Status.find(id).default?).to be_truthy }
  end

  it '#default? returns false if status.id bigger than 7' do
    expect(@status.default?).to be_falsey
  end

  it '#to_s? returns status name' do
    Status.all.each { |status| expect(status.to_s).to eq status.name }
  end

  it '#default_statuses_changes prevent changing default statuses names' do
    Status::DEFAULT_STATUSES.each_value do |params_status|
      status = Status.find(params_status[:id])
      status.update(name: 'SomeNewStatusName')
      expect(Status.find(params_status[:id]).name).to eq params_status[:name]
    end
  end

  it '#default_statuses_changes add error message when trying to change default statuses' do
    Status::DEFAULT_STATUSES.each_value do |params_status|
      status = Status.find(params_status[:id])
      status.update(name: 'SomeNewStatusName')
      errors_messages = status.errors.messages[:id]

      expect(errors_messages.include?('Can`t change default status')).to be_truthy
    end
  end

  describe '#default_statuses_ids' do

    before(:each) do
      @deafault_elements_ids = []
      Status::DEFAULT_STATUSES.each_value do |params_status|
        @deafault_elements_ids << params_status[:id]
      end
    end

    it '#default_statuses_changes allow changing not default statuses name' do
      new_name = 'SomeNewStatusName'
      subject.update(name: new_name)

      expect(Status.find_by(name: new_name).name).to eq new_name
    end

    it 'returns only default statuses ids' do

      expect(@status.send(:default_statuses_ids)).to eq @deafault_elements_ids
    end

    it 'does not returns not default statuses ids' do

      expect(@status.send(:default_statuses_ids).include?(@status.id)).to be_falsey
    end
  end

  it '#move_issues_to_submitted change status issues to "Submitted"' do
    project = create(:setup_project)

    10.times do
      issue = create(:issue, project_id: project.id)
      @status.issues << issue
    end

    replaced_issues_ids = @status.issues.map { |issue| issue.id }

    @status.send(:move_issues_to_submitted)
    submitted_status_id = Status.find_by(name: 'Submitted').id
    replaced_issues_ids.each do |id|
      expect(Issue.find(id).status_id).to eq submitted_status_id
    end
  end

  it 'default statuses can`t be deleted' do

    Status.all.each do |status|
      next unless status.default?
      status_id = status.id

      expect(Status.find(status_id).persisted?).to be_truthy
      expect(Status.exists?(status_id)).to be_truthy
    end
  end

  it 'default statuses issues are not replaced before deletion' do

    Status.all.each do |status|
      next unless status.default?
      status_id = status.id

      issues_ids = status.issues.map { |issue| issue.id }

      status.destroy

      issues_ids.each do |issue_id|

        issue = Issue.find(issue_id)
        expect(issue.status_id).to eq status_id
      end
    end
  end
end
