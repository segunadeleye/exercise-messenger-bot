class Routine < ApplicationRecord
  belongs_to :workout
  belongs_to :exercise

  def next_routine
    Routine.where(workout_id: workout_id).where('id > ?', id).first
  end
end
