FactoryGirl.define do
  factory :role do
    factory :role_owner do
      role Role.role.values.find_index(:owner)
    end

    factory :role_admin do
      role Role.role.values.find_index(:admin)
    end

    factory :role_user do
      role Role.role.values.find_index(:user)
    end

    factory :role_developer do
      role Role.role.values.find_index(:developer)
    end

    factory :role_tester do
      role Role.role.values.find_index(:tester)
    end

    factory :role_viewer do
      role Role.role.values.find_index(:viewer)
    end

    factory :role_project_manager do
      role Role.role.values.find_index(:project_manager)
    end
  end
end
