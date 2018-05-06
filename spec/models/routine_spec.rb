require 'rails_helper'

describe Routine, type: :model do
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
end
