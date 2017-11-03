require 'rails_helper'

RSpec.describe ProjectPolicy do

  # let(:user) { FactoryGirl.create(:user) }

  subject { described_class }

  permissions :update? do

  end

  permissions :member? do

  end

  permissions :viewer? do

  end

  permissions :not_viewer? do

  end

  permissions :tester_or_higher_rank? do

    it 'permit for owner' do
      @user = FactoryGirl.create(:user)
      create_test_data
      expect(subject).to permit(@user, @proj_1)
    end

    it 'permit for admin' do
      @user = FactoryGirl.create(:user)
      create_test_data
      expect(subject).to permit(@user_2, @proj_1)
    end
  end

  permissions :developer_or_higher_rank? do

  end

  permissions :project_manager_or_higher_rank? do

  end

  permissions :admin_or_higher_rank? do

  end

  permissions :owner? do

  end



  # permissions ".scope" do
  #   pending "add some examples to (or delete) #{__FILE__}"
  # end
end
