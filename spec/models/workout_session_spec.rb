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
  end
end
