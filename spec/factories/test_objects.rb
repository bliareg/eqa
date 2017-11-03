FactoryGirl.define do
  factory :test_object do
    factory :apk_build do
      before :create do |instance|
        instance.file = File.new("#{Rails.root}/spec/fixtures/mobile_builds/app-debug.apk")
      end
    end
    factory :ipa_build do
      before :create do |instance|
        instance.file = File.new("#{Rails.root}/spec/fixtures/mobile_builds/example.ipa")
      end
    end
    factory :web do
      link { Faker::Internet.url(Faker::Internet.domain_name, '') }
    end
  end
end
