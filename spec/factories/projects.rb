FactoryGirl.define do
  factory :project do
    sequence(:title) { |n| Faker::App.name + n.to_s }
    sequence(:token) { |n| SecureRandom.base64(24) + n.to_s }

    factory :setup_project do
      before :create do |instance|
        create(:status)
        user = create(:user)
        organization = create(:organization)
        organization.roles << build(:role_owner, user_id: user.id)
        instance.user_id = user.id
        instance.organization_id = organization.id
      end
    end

  end
end
