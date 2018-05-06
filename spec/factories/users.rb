FactoryBot.define do
  factory :user do
    sender_id { Faker::Number.number(16) }
  end
end
