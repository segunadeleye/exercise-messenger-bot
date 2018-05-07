class User < ApplicationRecord
  has_many :workout_sessions

  validates :sender_id, presence: true

  def has_pending_workout_session?
    workout_sessions.pending.present?
  end
end
