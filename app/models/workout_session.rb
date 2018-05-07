class WorkoutSession < ApplicationRecord
  belongs_to :user
  belongs_to :workout

  STATUS = { pending: 0, complete: 1, incomplete: 2 }

  scope :pending, -> { where(status: STATUS[:pending]) }
end
