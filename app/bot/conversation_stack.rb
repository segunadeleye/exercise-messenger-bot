class ConversationStack
  attr_reader :workout_session, :user, :sender_id, :command

  def initialize(sender_id)
    @sender_id = sender_id
  end

  class << self
    def stack
      @@stack ||= {}
    end

    def add(sender_id)
      stack[sender_id] = new(sender_id)
    end

    def remove(sender_id)
      stack.delete sender_id
    end
  end

  def add_user(user)
    @user = user
  end

  def add_workout_session(workout_session)
    @workout_session = workout_session
  end

  def next_command(_command, args = [])
    @command = [_command, args]
  end
end
