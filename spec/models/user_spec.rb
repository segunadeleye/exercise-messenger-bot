require 'rails_helper'

RSpec.describe User, type: :model do
  context 'table structure' do
    it { should have_db_column(:sender_id) }
    it { should have_db_index(:sender_id) }
  end

  context 'validations' do
    it { should validate_presence_of(:sender_id) }
  end
end
