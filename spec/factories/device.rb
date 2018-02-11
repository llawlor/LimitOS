FactoryBot.define do
  factory :device do
    sequence(:name) { |n| "my_device_#{n}" }
    device_type 'raspberry_pi'
    association :user
  end
end
