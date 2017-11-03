FactoryGirl.define do
  factory :status do
    name { Faker::Hacker.ingverb }

    transient do
      project_id nil
    end

    before(:create) do
      all_statuses = Status.pluck(:name)

      Status::DEFAULT_STATUSES.each_value do |params_status|
        Status.create(name: params_status[:name]) unless all_statuses.include?(params_status[:name])
        Status.find_by(name: params_status[:name]).update_attribute(:id, params_status[:id])
      end
    end

    after :create do |instance, evaluator|
      if evaluator.project_id.present?
        instance.project_statuses.create(project_id: evaluator.project_id)
      end
    end

  end
end
