require 'rails_helper'

describe ExerciseBot do
  let(:quick_replies) { {
    yes: {
      content_type: 'text',
      title: 'Yes',
      payload: 'YES'
    },
    no: {
      content_type: 'text',
      title: 'No',
      payload: 'NO'
    },
    done: {
      content_type: 'text',
      title: 'Done',
      payload: 'DONE'
    }
  } }

  it { expect(described_class).to respond_to(:listen) }
  it { expect(ExerciseBot::QUICK_REPLIES).to eq(quick_replies) }
end
