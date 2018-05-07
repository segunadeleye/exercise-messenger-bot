class PerformedRoutine < ApplicationRecord
  belongs_to :workout_session
  belongs_to :routine
end
