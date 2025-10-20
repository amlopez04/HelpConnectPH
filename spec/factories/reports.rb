FactoryBot.define do
  factory :report do
    title { Faker::Lorem.sentence(word_count: 5) }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    address { Faker::Address.full_address }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    status { :pending }
    priority { :medium }
    
    association :user
    association :barangay
    association :category

    trait :pending do
      status { :pending }
    end

    trait :in_progress do
      status { :in_progress }
    end

    trait :resolved do
      status { :resolved }
      resolved_at { Time.current }
    end

    trait :closed do
      status { :closed }
    end

    trait :low_priority do
      priority { :low }
    end

    trait :medium_priority do
      priority { :medium }
    end

    trait :high_priority do
      priority { :high }
    end

    trait :critical_priority do
      priority { :critical }
    end
  end
end

