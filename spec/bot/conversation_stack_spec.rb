require 'rails_helper'

describe ConversationStack do
  let(:sender_id) { 123456789 }
  let(:another_sender_id) { 987654321 }
  let(:user) { create(:user) }
  let(:workout_session) { create(:workout_session) }
  let(:conversation_stack) { described_class.new(sender_id) }
  let(:another_conversation_stack) { described_class.new(another_sender_id) }

  describe '.stack' do
    it { expect(described_class.stack).to eq({}) }

    describe 'add and remove item' do
      before do
        allow(described_class).to receive(:new).and_return(conversation_stack)
        allow(described_class).to receive(:new).with(another_sender_id).and_return(another_conversation_stack)

        described_class.add(sender_id)
        described_class.add(another_sender_id)
      end

      context '.add' do
        it { expect(described_class.stack).to eq({ sender_id => conversation_stack, another_sender_id => another_conversation_stack }) }
        it { expect(described_class.stack[sender_id]).to eq(conversation_stack) }
      end

      context 'remove' do
        before { described_class.remove(sender_id) }

        it { expect(described_class.stack[sender_id]).to be_nil }
        it { expect(described_class.stack[another_sender_id]).to eq(another_conversation_stack) }
        it { expect(described_class.stack).to eq({ another_sender_id => another_conversation_stack }) }
      end
    end
  end

  describe '#add_user' do
    before { conversation_stack.add_user(user) }
    it { expect(conversation_stack.user).to eq(user) }
  end

  describe '#add_workout_session' do
    before { conversation_stack.add_workout_session(workout_session) }
    it { expect(conversation_stack.workout_session).to eq(workout_session) }
  end

  describe '#next_command' do
    before { conversation_stack.next_command(:generic_method, [1]) }
    it { expect(conversation_stack.command).to eq([:generic_method, [1]]) }
  end
end
