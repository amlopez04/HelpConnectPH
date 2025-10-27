FactoryBot.define do
  factory :barangay do
    name { Faker::Address.community }
    description { Faker::Lorem.paragraph }
    address { Faker::Address.full_address }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    contact_number { Faker::PhoneNumber.phone_number }
    contact_email { Faker::Internet.email }
  end
end
