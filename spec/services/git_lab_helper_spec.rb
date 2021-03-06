require 'rails_helper'

RSpec.describe GitLabHelper do
  before :all do
    project = create(:setup_project)
    @setting = create(:git_lab_setting, project: project)
    @helper = @setting.helper
  end

  context 'initialize' do
    it 'base_url' do
      @helper.base_url.should == @setting.base_url
    end

    it 'access_token' do
      @helper.access_token.should == @setting.access_token
    end

    it 'service_project_id' do
      @helper.service_project_id.should == @setting.service_project_id
    end
  end

  context 'check_connection' do
    it 'must don`t raise error' do
      expect { @helper.check_connection }.not_to raise_error
    end

    it 'must raise Faraday::ConnectionFailed' do
      helper = build(:you_track_setting, project: @setting.project,
                                         login: 'stub').helper
      expect { helper.check_connection }.to raise_error(StandardError)
    end
  end

  context 'project_by_name' do
    context 'success' do
      before :all do
        # Taking name from git_lab_setting factories
        @response = @helper.project_by_name('Hoshylyk/Testing')
      end

      it 'should be complete' do
        @response[:complete].should == true
      end

      it 'message must be success' do
        @response[:message].should == 'Success'
      end

      it 'body id must be equal service_project_id' do
        @response[:body]['id'].should == @setting.service_project_id
      end
    end

    context 'failure' do
      before :all do
        # Random name. You must be sure that the name on the site does not exist
        @response = @helper.project_by_name('RandomUserName/RandomProject')
      end

      it 'complete should be false' do
        @response[:complete].should == false
      end

      it 'error message must be present' do
        @response[:message].should == '404 Project Not Found'
      end
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

    context 'issue body' do
      it 'summary must be created' do
        @response[:body][:summary].should == @issue.summary
      end

      it 'description must be created' do
        @response[:body][:description].should == @issue.description
      end

      it 'status must be equal submitted' do
        @response[:body][:status_id].should == Status::DEFAULT_STATUSES[:submitted][:id]
      end
    end
  end

  context 'update_issue' do
    before :all do
      @issue_id = @helper.create_issue(attributes_for(:issue))[:body][:id]
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
        response = @helper.update_issue(@issue.attributes, @issue_id)
        response[:body][:status_id].should == Status::DEFAULT_STATUSES[:closed][:id]
      end
    end
  end

  context 'destroy_issue' do
    before :all do
      issue_id = @helper.create_issue(attributes_for(:issue))[:body][:id]
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
      @issue = @helper.create_issue(attributes_for(:issue))[:body]
      @response = @helper.show_issue(@issue[:id])
    end

    it 'should be complete' do
      @response[:complete].should == true
    end

    it 'message must be success' do
      @response[:message].should == 'Success'
    end

    it 'body must be present' do
      @response[:body].should == @issue
    end
  end

  context 'all_service_issues' do
    before :all do
      @issue = @helper.create_issue(attributes_for(:issue))[:body]
      @response = @helper.all_service_issues
    end

    it 'issue must be present' do
      @response[@issue[:id]].should == @issue
    end
  end
end
