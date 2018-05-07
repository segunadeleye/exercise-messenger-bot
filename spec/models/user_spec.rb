require 'rails_helper'

describe User, type: :model do
  context 'table structure' do
    it { should have_db_column(:sender_id) }
    it { should have_db_index(:sender_id) }
  end

  context 'validations' do
    it { should validate_presence_of(:sender_id) }
  end

  describe 'association' do
    it { should have_many(:workout_sessions) }
  end

  describe '#has_pending_workout_session?' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:workout) { create(:workout) }
    let!(:workout_session_1) { WorkoutSession.create(user_id: user1.id, workout_id: workout.id) }
    let!(:workout_session_2) { WorkoutSession.create(user_id: user2.id, workout_id: workout.id, status: 1) }

    context 'user with pending session' do
      it { expect(user1.has_pending_workout_session?).to eq(true) }
    end

    context 'user without pending session' do
      it { expect(user2.has_pending_workout_session?).to eq(false) }
    end
  end
end
