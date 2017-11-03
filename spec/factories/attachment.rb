FactoryGirl.define do
  factory :attachment do
    factory :jpg_image do
      before :create do |instance|
        instance.file = File.new("#{Rails.root}/spec/fixtures/images/test.jpg")
      end
    end

    factory :mp4_video do
      before :create do |instance|
        instance.file = File.new("#{Rails.root}/spec/fixtures/videos/test.mp4")
      end
    end
  end
end
