require 'rails_helper'

describe WorkoutSession, type: :model do
  describe 'db columns and indexes' do
    it { should have_db_column(:status) }

    it { should have_db_index(:user_id) }
    it { should have_db_index(:workout_id) }
    it { should have_db_index(:status) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:workout) }
    it { should have_many(:performed_routines) }
    it { should have_many(:routines).through(:performed_routines) }
  end

  describe 'STATUS' do
    it { expect(WorkoutSession::STATUS).to eq({ pending: 0, complete: 1, incomplete: 2 }) }
  end

  describe 'scope' do
    let(:user) { create(:user) }
    let(:workout) { create(:workout) }
    let!(:workout_sessions) { create_list(:workout_session, 5, user_id: user.id, workout_id: workout.id) }

    describe '.pending' do
      it { expect(described_class.pending.count).to eq(5) }
      it { expect(described_class.pending).to eq(workout_sessions) }
    end
  end
end
