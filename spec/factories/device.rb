FactoryGirl.define do
  factory :device do
    name 'my_device'
    device_type 'raspberry_pi'
    association :user
  end
end
