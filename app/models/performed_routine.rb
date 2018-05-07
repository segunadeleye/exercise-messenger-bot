class PerformedRoutine < ApplicationRecord
  belongs_to :workout_session
  belongs_to :routine

  STATUS = { skipped: 0, done: 1 }
end
