require 'rails_helper'

RSpec.describe User, type: :model do
  it 'factory is valid' do
    expect(create(:user).valid?).to be_truthy
  end

  describe 'validations' do
    context 'names' do
      it 'with deprecated symbols first name is invalid' do
        user = build(:user, first_name: 'a,.0/+=!@#$^&**()%}-79b')

        expect(user.valid?).to be_falsey
      end

      it 'first name can include digits' do
        user = create(:user, first_name: '9-9-9-')

        expect(user.valid?).to be_truthy
      end

      it 'with deprecated symbols last name is invalid' do
        user = build(:user, last_name: 'a,.0/+=!@#$^&**()%}-79b')

        expect(user.valid?).to be_falsey
      end

      it 'last name can include digits' do
        user = create(:user, last_name: '9-9-9-')

        expect(user.valid?).to be_truthy
      end
    end

    context 'password' do
      it 'user invalid without password' do
        user = build(:user, password: nil, password_confirmation: nil)

        expect(user.valid?).to be_falsey
      end

      it 'must be more than 6 symbols' do
        user = build(:user, password: 'passw', password_confirmation: 'passw')

        expect(user.valid?).to be_falsey
      end

      it 'must be less than 60 symbols' do
        password = ''
        61.times { password << 'a'}
        user = build(:user,
                     password: password, password_confirmation: password)

        expect(user.valid?).to be_falsey
      end

      it 'with deprecated symbols is invalid' do
        user = build(:user,
                     password: 'a,.0/+=!@#$|\^&**()%}-79b',
                     password_confirmation: 'a,.0/+=!@#$|\^&**()%}-79b')

        expect(user.valid?).to be_falsey
      end
    end

    context 'email' do
      let(:user_1) { create(:user, email: 'x@x.com', provider: 'SoftServ') }

      it 'user invalid without email' do
        user_2 = build(:user, email: nil)

        expect(user_2.valid?).to be_falsey
      end

      it 'is case insencitive' do
        user_1
        user_2 = build(:user, email: 'X@X.com', provider: 'SoftServ')

        expect(user_2.valid?).to be_falsey
      end

      it 'same email from same provider for another user is invalid' do
        user_1
        user_2 = build(:user, email: 'x@x.com', provider: 'SoftServ')

        expect(user_2.valid?).to be_falsey
      end

      # it 'same email for different providers is valid' do
      #   user_1
      #   user_2 = build(:user, email: 'x@x.com', provider: 'Microsoft')

      #   expect(user_2.valid?).to be_truthy
      # end
    end
    context 'attachment' do
    end
  end

  describe 'instance and class methods' do
    before :each do
      @user = FactoryGirl.create(:user)
      create_test_data
    end

    it '#name returns first and last name' do
      expect(@user.name).to eq("#{@user.first_name} #{@user.last_name}")
    end

    it '#organizations return user organization instances' do
      id_s = [Organization.find_by(title: 'Organization_1'),
              Organization.find_by(title: 'Organization_2')]

      expect(@user.organizations.sort).to eq id_s.sort
    end

    it '#members_projects return user projects' do
      Role.create(user_id: @user_2.id, organization_id: @org_1.id,
                  project_id: @proj_1.id, role: 5)
      Role.create(user_id: @user_2.id, organization_id: @org_1.id,
                  project_id: @proj_2.id, role: 5)

      projects = [@proj_1, @proj_2]
      members_projects = @user_2.organization_projects(@org_1.id)
                                .map { |project| project }

      expect(members_projects).to match_array projects
    end

    it '#project_role return instance of Role which belongs to project' do
      @proj_1.roles.destroy_all
      role1 = create(:role, user_id: @user_2.id,
                            organization_id: @org_1.id,
                            project_id: @proj_1.id,
                            role: 5)
      user_role = @user_2.project_role(@proj_1.id)

      expect(user_role).to eq role1
    end

    it '#organization_role return instance of Role which belongs to organization' do
      @org_1.roles.destroy_all
      organization_role = create(:role, user_id: @user_2.id,
                                        organization_id: @org_1.id,
                                        role: 2)

      user_role = @user_2.organization_role(@org_1.id)

      expect(user_role).to eq organization_role
    end

    it '.employees return User instances for user projects' do
      user_3 = FactoryGirl.create(:user)
      user_4 = FactoryGirl.create(:user)
      user_5 = FactoryGirl.create(:user)
      user_6 = FactoryGirl.create(:user)
      user_7 = FactoryGirl.create(:user)


      [@user_2, user_3].each do |user|
        Role.create(user_id: user.id, organization_id: @org_1.id,
                    role: 3)

        Role.create(user_id: user.id, organization_id: @org_1.id,
                    project_id: @proj_1.id, role: 5)
      end
      Role.create(user_id: user_4.id, organization_id: @org_1.id,
                  role: 3)
      Role.create(user_id: user_4.id, organization_id: @org_1.id,
                  project_id: @proj_2.id, role: 5)
      Role.create(user_id: user_6.id, organization_id: @org_1.id, role: 2)

      user_employees = [@user_2, user_3, user_4, user_6]
      expect(@user.employees).to match_array user_employees
    end
  end
end
