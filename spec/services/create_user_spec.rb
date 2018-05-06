require 'rails_helper'

describe CreateUser do
  let(:sender_id) { Faker::Number.number(16) }

  describe '#call' do
    context 'user does not exist' do
      it 'increment count of user by 1' do
        expect{CreateUser.new(sender_id).call}.to change{User.count}.by(1)
      end

      it 'creates new user' do
        result = CreateUser.new(sender_id).call
        expect(result[:new_user]).to eq(true)
        expect(result[:user].sender_id).to eq(sender_id)
      end
    end

    context 'user exists' do
      let!(:user) { create(:user) }

      it 'user count remains the same' do
        expect{CreateUser.new(user.sender_id).call}.to change{User.count}.by(0)
      end

      it 'does not create new user' do
        result = CreateUser.new(user.sender_id).call
        expect(result[:new_user]).to eq(false)
        expect(result[:user].sender_id).to eq(user.sender_id)
      end
    end
  end
end
