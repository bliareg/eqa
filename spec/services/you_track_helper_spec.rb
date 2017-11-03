require 'rails_helper'

RSpec.describe YouTrackHelper do
  before :all do
    setup_statuses
    project = create(:setup_project)
    @setting = create(:you_track_setting, project: project)
    @helper = @setting.helper
  end

  context 'initialize' do
    it 'base_url' do
      @helper.base_url.should == @setting.base_url
    end

    it 'service_pid' do
      @helper.service_pid.should == @setting.service_pid
    end

    it 'login' do
      @helper.login.should == @setting.login
    end

    it 'password' do
      @helper.password.should == @setting.password
    end

    it 'agile_board_name' do
      @helper.agile_board_name.should == @setting.agile_board_name
    end

    it 'sprint_name' do
      @helper.sprint_name.should == @setting.sprint_name
    end

    it 'user cookie must be set' do
      @helper.user_cookie.present?.should == true
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

    it 'id in body must be present' do
      @response[:body][:id].should == @issue_id
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
      issue_id = @helper.create_issue(build(:issue).attributes)[:body][:id]
      @issue = @helper.show_issue(issue_id)[:body]
      @response = @helper.all_service_issues
    end

    it 'issue must be present' do
      @response[@issue[:id]].should == @issue
    end
  end

  context 'attachments' do
    before :all do
      @issue = build(:issue, project_id: @setting.project.id)
      @issue_id = @helper.create_issue(@issue.attributes)[:body][:id]
      file_path = "#{Rails.root}/spec/fixtures/images/test.jpg"
      @response = @helper.create_attachment(file_path, 'image/jpg', @issue_id)
    end

    context 'create' do
      it 'should be create' do
        @response[:complete].should == true
      end

      it 'message must be success' do
        @response[:message].should == 'Success'
      end

      it 'id in body must be present' do
        @response[:body][:id].present?.should == true
      end
    end

    context 'destroy' do
      it 'should be destroy' do
        response = @helper.destroy_attachment(@issue_id, @response[:body][:id])
        response[:complete].should == true
      end
    end
  end
end
