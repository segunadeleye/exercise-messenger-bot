class GetPendingRoutine
  include Service

  def initialize(workout_session)
    @workout_session = workout_session
  end

  def call
    return nil if workout_session.status != 0
    pending_routine
  end

private
  attr_reader :workout_session

  def pending_routine
    if workout_session.routines.blank?
      workout_session.workout.routines.first
    else
      workout_session.routines.last.next_routine
    end
  end
end
