FactoryBot.define do
  factory :exercise do
    name { Faker::Lorem.word }
    picture { Faker::Internet.url }
    video { Faker::Internet.url }
    purpose { Faker::Lorem.paragraph }
  end
end
