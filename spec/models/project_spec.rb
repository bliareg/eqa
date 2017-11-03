require 'rails_helper'

RSpec.describe Project, type: :model do
  subject { FactoryGirl.create(:setup_project) }

  it 'factory :projectis valid' do
    expect(subject.valid?).to be_truthy
  end

  it 'factory "setup_project" is valid' do
    expect(subject.valid?).to be_truthy
  end

  describe "Associations" do
    it { should belong_to(:organization) }
    it { should belong_to(:owner) }

    it { should have_many(:issues) }
    it { should have_many(:plugins).through(:issues) }
    it { should have_many(:crashes).through(:test_objects) }
    it { should have_many(:log_files).through(:crashes) }
    it { should have_many(:notifications).dependent(:destroy) }
    it { should have_many(:project_statuses) }
    it { should have_many(:roles).dependent(:destroy) }
    it { should have_many(:statuses).through(:project_statuses) }
    it { should have_many(:test_cases).through(:test_plans) }
    it { should have_many(:test_modules).through(:test_plans) }
    it { should have_many(:users).through(:roles) }
    it { should have_many(:test_plans) }
    it { should have_many(:test_runs) }
    it { should have_many(:versions) }
    it { should have_many(:git_lab_settings) }
    it { should have_many(:git_hub_settings) }
    it { should have_many(:you_track_settings) }

    it { should have_one(:logo) }

    it { should accept_nested_attributes_for(:logo) }
    it { should have_and_belong_to_many (:platforms) }
  end

  describe "Validations" do
    it { should validate_length_of(:title) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:user_id) }

    it { should validate_uniqueness_of(:token) }
  end

  describe 'Appropriate attributes' do
    context 'with invalid attributes' do
      it 'is invalid without title' do
        subject.title = nil
        expect(subject.valid?).to be_falsey
      end

      it 'is invalid without user' do
        subject.user_id = nil
        expect(subject.valid?).to be_falsey
      end
    end
  end

  describe 'Model methods properly working' do

    it '#members_by_project_id return project members sorted by project id' do

      user_1 = create(:user, project: subject, organization: subject.organization, role: :tester)
      user_2 = create(:user, project: subject, organization: subject.organization, role: :tester)
      another_project = FactoryGirl.create(:setup_project)
      10.times do |i|
        create(:user, invitation_token: nil,
                      project: another_project,
                      organization: another_project.organization, role: :tester)
      end

      founded_members = Project.members_by_project_id(subject.id).order(:id)
      expect(founded_members).to match_array([User.find(subject.user_id), user_1, user_2])
    end

    context "destoy objects" do

      it 'should destroy object step#1' do
        @restore_object = subject.destroy

        expect(Project.only_deleted.first.id.equal?(@restore_object.id) &&
               !Project.find_by_id(@restore_object.id)).to be_truthy
      end

      it 'should restore object step#2' do
        @restore_object = subject.destroy
        Project.restore(@restore_object.id)

        expect(Project.find_by_id(@restore_object.id).present?).to be_truthy
      end
    end

    it '#members_data_with_key works properly' do
      user_1 = create(:user, project: subject, organization: subject.organization, role: :tester)
      user_2 = create(:user, project: subject, organization: subject.organization, role: :tester)
      user = User.find(subject.user_id)
      data = [{ name: user.name,   email: user.email, id: user.id },
              { name: user_2.name, email: user_2.email, id: user_2.id },
              { name: user_1.name, email: user_1.email, id: user_1.id }]

      expect(subject.members_data_with_key(:email)).to match_array(data)
    end

    it "should contains constants" do
      project_constants = %i(PLUGINS SETTING_PARAMS AMOUNT_ON_PAGE EASY_QA)

      project_constants.each do |const|
        expect(Project.const_defined?(const)).to be_truthy
      end
    end
  end
end
