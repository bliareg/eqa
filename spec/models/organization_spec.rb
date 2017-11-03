require 'rails_helper'

RSpec.describe Organization, type: :model do
  it 'factory is valid' do
    expect(create(:organization).valid?).to be_truthy
  end

  it 'is invalid without title' do
    expect(build(:organization, title: nil).valid?).to be_falsey
  end

  it 'is invalid with title more than 150 symbols' do
    title = '1a2b3c'
    while title.length < 151 do
      title << title
    end

    expect(build(:organization, title: title).valid?).to be_falsey
  end

  # it 'title must be capitalized before saving' do
  #   organization = Organization.new(title: 'thinkMobiles')

  #   expect(organization.title).to eq 'ThinkMobiles'
  # end

  describe 'instance and class methods' do
    before :each do
      @user = FactoryGirl.create(:user)
      create_test_data
      @org_2 = Organization.find_by(title: 'Organization_2')
    end

    it '#owner returns User instance' do
      expect(@org_1.owner).to eq @user
    end

    it '#members return User instances which has particular organization roles' do
      user_3 = create(:user)
      user_4 = create(:user)
      user_5 = create(:user)

      [user_3, user_4].each do |user|
        Role.create(user_id: user.id, organization_id: @org_1.id, role: 5)
      end
      Role.create(user_id: user_5.id, organization_id: @org_2.id, role: 5)

      organization_members = [@user, @user_2, user_3, user_4]
      expect(@org_1.members.to_a).to match_array organization_members
    end

    it '#employees organization users without owner' do
      user_3 = FactoryGirl.create(:user)
      user_4 = FactoryGirl.create(:user)
      user_5 = FactoryGirl.create(:user)
      user_6 = FactoryGirl.create(:user)

      [@user_2, user_3, user_4, user_6].each do |user|
        Role.create(user_id: user.id, organization_id: @org_1.id, role: 5)
      end
      Role.create(user_id: user_5.id, organization_id: @org_2.id, role: 5)

      organization_employees = [@user_2, user_3, user_4, user_6]

      expect(@org_1.employees.to_a).to match_array organization_employees
    end

    it 'employees_count' do
      user_3 = FactoryGirl.create(:user)
      user_4 = FactoryGirl.create(:user)
      user_5 = FactoryGirl.create(:user)
      user_6 = FactoryGirl.create(:user)

      [@user_2, user_3].each do |user|
        Role.create(user_id: user.id, organization_id: @org_1.id, role: 5)
      end
      Role.create(user_id: user_5.id, organization_id: @org_2.id, role: 5)
      Role.create(user_id: user_4.id, organization_id: @org_1.id, role: 5)
      Role.create(user_id: user_6.id, organization_id: @org_1.id, role: 5)

      organization_employees = [@user_2, user_3, user_4, user_6]

      expect(@org_1.employees.length).to eq organization_employees.length
    end

    it '.with_user return organizations where user is member' do
      org1 = Organization.find_by(title: 'Organization_1')
      org2 = Organization.find_by(title: 'Organization_2')

      user3 = create(:user)

      org4 = create(:organization, title: 'Organization_4')
      org4.roles << build(:role_owner, user_id: user3.id)
      org4.roles << build(:role_user, user_id: @user.id)

      organizations_with_user = [org1, org2, org4]
      expect(Organization.with_user(@user)).to match_array organizations_with_user
    end
  end
end
