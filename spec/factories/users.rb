# examples

# @developer               = create(:user, with_token: true, project: @project, role: :developer)
# @organization_user       = create(:user, with_token: true, organization: @organization, role: :user)
# roles  owner: 0, admin: 1, user: 2, developer: 3, tester: 4, viewer: 5, project_manager: 6

FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    provider   { Faker::Company.name }
    uid        { Faker::Code.ean }
    company    { Faker::Company.name }
    email      { Faker::Internet.email }
    confirmed_at { Time.now }

    current_sign_in_ip '0.0.0.0'

    password 'foobarrr'
    password_confirmation 'foobarrr'

    transient do
      with_token false
      project nil
      organization nil
      role nil
    end

    after :create do |instance, evaluator|
      instance.authenticity_tokens << build(:authenticity_token) if evaluator.with_token

      if evaluator.project
        evaluator.project.organization.roles << build(:role_user, user_id: instance.id)

        evaluator.project.roles << build("role_#{evaluator.role}",
                                         user_id: instance.id,
                                         organization_id: evaluator.project.organization_id)
      elsif evaluator.organization
        evaluator.organization.roles << build("role_#{evaluator.role}", user_id: instance.id)
      end
    end
  end
end
