FactoryBot.define do
  factory :barangay do
    name { Faker::Address.community }
    description { Faker::Lorem.paragraph }
    address { "Parañaque, Metro Manila, Philippines" }
    # Use Parañaque City coordinates
    latitude { 14.4793095 }
    longitude { 121.0198229 }
    contact_number { Faker::PhoneNumber.phone_number }
    contact_email { Faker::Internet.email }
  end
end
