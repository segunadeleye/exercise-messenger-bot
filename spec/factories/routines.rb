FactoryBot.define do
  factory :routine do
    set { Faker::Number.number(2) }
    repetition { Faker::Number.number(2) }
    preparation { Faker::Number.number(2) }
    start { Faker::Number.number(2) }
    hold { Faker::Number.number(2) }
    release { Faker::Number.number(2) }
    pause { Faker::Number.number(2) }
    position { Faker::Number.number(2) }
  end
end
