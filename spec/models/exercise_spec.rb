require 'rails_helper'

describe Exercise, type: :model do
  describe 'db columns' do
    it { should have_db_column(:name) }
    it { should have_db_column(:picture) }
    it { should have_db_column(:video) }
    it { should have_db_column(:purpose) }
  end
end
