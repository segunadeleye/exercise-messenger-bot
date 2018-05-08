class WorkoutSession < ApplicationRecord
  belongs_to :user
  belongs_to :workout

  has_many :performed_routines
  has_many :routines, through: :performed_routines

  STATUS = { pending: 0, complete: 1, incomplete: 2 }

  scope :pending, -> { where(status: STATUS[:pending]) }
end
