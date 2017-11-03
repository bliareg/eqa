FactoryGirl.define do
  factory :organization do
    transient do
      owner_id nil
    end

    sequence(:title) { |n| "Organization#{n}" }
    description { "#{title} - the best company in the world." }

    after :create do |instance, evaluator|
      create(:role_owner,
             user_id: evaluator.owner_id,
             organization_id: instance.id) if evaluator.owner_id.present?
    end
  end
end
