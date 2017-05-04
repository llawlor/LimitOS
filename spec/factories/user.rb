FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "email_#{n}@example.org"}
    password 'password123'
    password_confirmation 'password123'
  end
end
