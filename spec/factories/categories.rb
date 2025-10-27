FactoryBot.define do
  factory :category do
    name { Faker::Lorem.unique.word.capitalize }
    description { Faker::Lorem.sentence }
    icon { [ "flood", "road", "light", "trash", "other" ].sample }
  end
end
