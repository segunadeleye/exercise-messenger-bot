require 'rails_helper'

describe CreateUser do

  describe '#call' do
    let(:sender_id) { Faker::Number.number(16) }
    let(:result) { CreateUser.call(sender_id) }

    context 'user does not exist' do
      it 'increments count of user by 1' do
        expect{ result }.to change{User.count}.by(1)
      end

      it 'creates new user' do
        expect(result[:new_user]).to eq(true)
        expect(result[:user].sender_id).to eq(sender_id)
      end
    end

    context 'user exists' do
      let!(:user) { create(:user) }
      let(:result) { CreateUser.call(user.sender_id) }

      it 'user count remains the same' do
        expect{ result }.to change{User.count}.by(0)
      end

      it 'does not create new user' do
        expect(result[:new_user]).to eq(false)
        expect(result[:user].sender_id).to eq(user.sender_id)
      end
    end
  end

end
