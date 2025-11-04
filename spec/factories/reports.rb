FactoryBot.define do
  factory :report do
    title { Faker::Lorem.sentence(word_count: 5) }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    address { "Parañaque, Metro Manila, Philippines" }
    # Use Parañaque City coordinates that pass validation
    latitude { 14.4793095 }
    longitude { 121.0198229 }
    status { :pending_approval }
    priority { :medium }

    association :user
    association :barangay
    association :category

    trait :pending_approval do
      status { :pending_approval }
    end

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

    trait :reopen_requested do
      status { :reopen_requested }
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
