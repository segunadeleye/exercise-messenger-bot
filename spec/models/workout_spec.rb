require 'rails_helper'

describe Workout, type: :model do
  describe 'db columns' do
    it { should have_db_column(:name) }
  end

  describe 'associations' do
    it { should have_many(:routines) }
    it { should have_many(:exercises).through(:routines) }
  end
end
