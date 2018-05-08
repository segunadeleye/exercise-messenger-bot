require 'rails_helper'

describe PerformedRoutine, type: :model do
  describe 'db columns and indexes' do
    it { should have_db_column(:status) }

    it { should have_db_index(:workout_session_id) }
    it { should have_db_index(:routine_id) }
    it { should have_db_index(:status) }
  end

  describe 'associations' do
    it { should belong_to(:workout_session) }
    it { should belong_to(:routine) }
  end

  describe 'STATUS' do
    it { expect(PerformedRoutine::STATUS).to eq({ skipped: 0, done: 1 }) }
  end
end
