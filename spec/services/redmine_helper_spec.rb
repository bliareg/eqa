require 'rails_helper'

RSpec.describe RedmineHelper do
  before :all do
    project = create(:setup_project)
    @setting = create(:redmine_setting, project: project)
    @helper = @setting.helper
  end

  context 'initialize' do
    it 'project_name' do
      @helper.project_name.should == @setting.project_name
    end

    it 'tracker_name' do
      @helper.tracker_name.should == @setting.tracker_name
    end

    it 'base_url' do
      @helper.base_url.should == @setting.base_url
    end

    it 'board_name' do
      @helper.api_key.should == @setting.api_key
    end
  end

  context 'create_issue' do
    before :all do
      @issue = build(:issue, project_id: @setting.project.id)
      @response = @helper.create_issue(@issue.attributes)
    end

    it 'should be complete' do
      @response[:complete].should == true
    end

    it 'message must be success' do
      @response[:message].should == 'Success'
    end

    it 'id in body must be present' do
      @response[:body][:id].present?.should == true
    end
  end

  context 'update_issue' do
    before :all do
      @issue_id = @helper.create_issue(build(:issue).attributes)[:body][:id]
      @issue = build(:issue)
      @response = @helper.update_issue(@issue.attributes, @issue_id)
    end

    it 'should be complete' do
      @response[:complete].should == true
    end

    it 'message must be success' do
      @response[:message].should == 'Success'
    end

    context 'issue body' do
      before :all do
        @response = @helper.show_issue(@issue_id)
      end

      it 'summary must be updated' do
        @response[:body][:summary].should == @issue.summary
      end

      it 'description must be updated' do
        @response[:body][:description].should == @issue.description
      end

      it 'status must be equal submitted' do
        @response[:body][:status_id].should == Status::DEFAULT_STATUSES[:submitted][:id]
      end

      it 'status must be equal closed' do
        @issue.status_id = Status::DEFAULT_STATUSES[:closed][:id]
        @helper.update_issue(@issue.attributes, @issue_id)
        response = @helper.show_issue(@issue_id)
        response[:body][:status_id].should == Status::DEFAULT_STATUSES[:closed][:id]
      end
    end
  end

  context 'destroy_issue' do
    before :all do
      issue_id = @helper.create_issue(build(:issue).attributes)[:body][:id]
      @response = @helper.destroy_issue(issue_id)
    end

    it 'should be complete' do
      @response[:complete].should == true
    end

    it 'message must be success' do
      @response[:message].should == 'Success'
    end
  end

  context 'show_issue' do
    before :all do
      @issue = build(:issue)
      @issue_id = @helper.create_issue(@issue.attributes)[:body][:id]
      @response = @helper.show_issue(@issue_id)
    end

    it 'should be complete' do
      @response[:complete].should == true
    end

    it 'message must be success' do
      @response[:message].should == 'Success'
    end

    context 'issue body' do
      it 'summary must be present' do
        @response[:body][:summary].should == @issue.summary
      end

      it 'description must be present' do
        @response[:body][:description].should == @issue.description
      end

      it 'id must be present' do
        @response[:body][:id].should == @issue_id
      end
    end
  end

  context 'all_service_issues' do
    before :all do
      @issue = @helper.create_issue(build(:issue).attributes)[:body]
      @response = @helper.all_service_issues
    end

    it 'issue must be present' do
      @response[@issue[:id]].present?.should == true
    end
  end
end
