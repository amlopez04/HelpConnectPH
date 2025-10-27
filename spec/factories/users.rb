FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }
    confirmed_at { Time.current }
    role { :resident }
    association :barangay

    trait :barangay_official do
      role { :barangay_official }
    end

    trait :admin do
      role { :admin }
      barangay { nil }
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end
  end
end
