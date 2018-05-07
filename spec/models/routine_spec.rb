require 'rails_helper'

describe Routine, type: :model do
  let(:workout) { create(:workout) }
  let(:exercises) { create_list(:exercise, 3) }
  let!(:first_routine) { create(:routine, workout_id: workout.id, exercise_id: exercises.first.id) }
  let!(:second_routine) { create(:routine, workout_id: workout.id, exercise_id: exercises.second.id) }
  let!(:third_routine) { create(:routine, workout_id: workout.id, exercise_id: exercises.last.id) }

  describe 'db columns' do
    it { should have_db_column(:workout_id) }
    it { should have_db_column(:exercise_id) }
    it { should have_db_column(:set) }
    it { should have_db_column(:repetition) }
    it { should have_db_column(:preparation) }
    it { should have_db_column(:start) }
    it { should have_db_column(:hold) }
    it { should have_db_column(:release) }
    it { should have_db_column(:pause) }
    it { should have_db_column(:position) }
  end

  describe 'association' do
    it { should belong_to(:workout) }
    it { should belong_to(:exercise) }
  end

  describe '#next_routine' do
    it { expect(first_routine.next_routine).to eq(second_routine) }
    it { expect(second_routine.next_routine).to eq(third_routine) }
    it { expect(third_routine.next_routine).to be_nil }
  end
end
