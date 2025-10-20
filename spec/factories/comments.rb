FactoryBot.define do
  factory :comment do
    content { Faker::Lorem.paragraph(sentence_count: 2) }
    
    association :user
    association :report
  end
end

