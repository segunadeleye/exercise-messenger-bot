require 'rails_helper'

describe GetPendingRoutine do
  let(:done) { PerformedRoutine::STATUS[:done] }
  let(:skipped) { PerformedRoutine::STATUS[:skipped] }
  let(:workout_session_status) { WorkoutSession::STATUS }

  let!(:user) { create(:user) }
  let!(:workout) { create(:workout) }
  let!(:exercises) { create_list(:exercise, 3) }

  let!(:workout_session_1) { create(:workout_session, user: user, workout: workout) }
  let!(:workout_session_2) { create(:workout_session, user: user, workout: workout) }
  let!(:workout_session_3) { create(:workout_session, user: user, workout: workout) }
  let!(:complete_workout_session) { create(:workout_session, user: user, workout: workout, status: workout_session_status[:complete]) }
  let!(:incomplete_workout_session) { create(:workout_session, user: user, workout: workout, status: workout_session_status[:incomplete]) }

  let!(:routine_1) { create(:routine, workout: workout, exercise: exercises.first) }
  let!(:routine_2) { create(:routine, workout: workout, exercise: exercises.second) }
  let!(:routine_3) { create(:routine, workout: workout, exercise: exercises.third) }

  let!(:performed_routine_1) { create(:performed_routine, workout_session: workout_session_1, routine: routine_1, status: skipped) }
  let!(:performed_routine_2) { create(:performed_routine, workout_session: workout_session_1, routine: routine_2, status: done) }

  let!(:performed_routine_3) { create(:performed_routine, workout_session: workout_session_3, routine: routine_1, status: skipped) }
  let!(:performed_routine_4) { create(:performed_routine, workout_session: workout_session_3, routine: routine_2, status: done) }
  let!(:performed_routine_5) { create(:performed_routine, workout_session: workout_session_3, routine: routine_3, status: done) }

  describe '#call' do
    context 'has pending routines' do
      it { expect(GetPendingRoutine.call(workout_session_1)).to eq(routine_3) }
      it { expect(GetPendingRoutine.call(workout_session_2)).to eq(routine_1) }
    end

    context 'has no pending routine' do
      it { expect(GetPendingRoutine.call(workout_session_3)).to be_nil }
    end

    context 'complete and incomplete workout sessions' do
      it { expect(GetPendingRoutine.call(complete_workout_session)).to be_nil }
      it { expect(GetPendingRoutine.call(incomplete_workout_session)).to be_nil }
    end
  end

end
