require 'facebook/messenger'

include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

class ExerciseBot
  QUICK_REPLIES = {
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
    },
    start: {
      content_type: 'text',
      title: 'Start',
      payload: 'START'
    },
    skip: {
      content_type: 'text',
      title: 'Skip',
      payload: 'SKIP'
    }
  }

  class << self
    def listen
      p 'Listening'
      Bot.on :message do |message|
        p 'Message Received'
        if conversation_stack[message.sender['id']]&.command
          p 'Executing Next Command!!!'
          command = conversation_stack[message.sender['id']].command
          args = [message] + command[1]
          method(command[0]).call(*args)
        else
          p 'Initializing Conversation'
          handle_initial_message(message)
        end
      end
    end

    def conversation_stack
      ConversationStack.stack
    end

    def handle_initial_message(message)
      user = CreateUser.call(message.sender['id'])

      ConversationStack.add(message.sender['id'])
      conversation_stack[message.sender['id']].add_user(user[:user])

      if user[:new_user]
        message.reply(text: 'Welcome Padwan! Your account has been created.')
        confirm_start_workout(message)
      else
        message.reply(text: 'Welcome Back Jedi! Good to have you back')
        check_incomplete_workout(message)
      end
    end

    def check_incomplete_workout(message)
      if conversation_stack[message.sender['id']].user.has_pending_workout_session?
        confirm_continue_workout(message)
      else
        confirm_start_workout(message)
      end
    end

    def confirm_continue_workout(message)
      message.reply({
        text: 'Would you like to continue from where you stopped?',
        quick_replies: [QUICK_REPLIES[:yes], QUICK_REPLIES[:no]]
      })
      next_command(message.sender['id'], :handle_continue_workout)
    end

    def handle_continue_workout(message)
      workout_session = conversation_stack[message.sender['id']].user.workout_sessions.pending.first
      conversation_stack[message.sender['id']].add_workout_session(workout_session)

      if message.quick_reply == 'YES'
        message.reply(text: "Let's get started!!!")
        initiate_exercise(message, GetPendingRoutine.call(workout_session))
      else
        workout_session.update(status: WorkoutSession::STATUS[:incomplete])
        confirm_start_workout(message)
      end
    end

    def confirm_start_workout(message)
      message.reply({
        text: 'Hi Human! Would you like to start a workout session?',
        quick_replies: [QUICK_REPLIES[:yes], QUICK_REPLIES[:no]]
      })

      next_command(message.sender['id'], :handle_start_workout)
    end

    def handle_start_workout(message)
      if message.quick_reply == 'YES'
        select_workout(message)
      else
        end_conversation(message.sender['id']) do
          message.reply(text: 'Alright! But you can come back whenever you feel like working out.')
        end
      end
    end

    def select_workout(message)
      message.reply({
        text: 'Please select a workout',
        quick_replies: Workout.all.map do |workout|
          {
            content_type: 'text',
            title: workout.name,
            payload: workout.id
          }
        end
      })

      next_command(message.sender['id'], :handle_select_workout)
    end

    def handle_select_workout(message)
      user = conversation_stack[message.sender['id']].user
      conversation_stack[message.sender['id']].add_workout_session(WorkoutSession.create(user: user, workout_id: message.quick_reply))
      initiate_exercise(message, Workout.find(message.quick_reply).routines.first)
    end

    def initiate_exercise(message, routine)
      send_exercise_information(message, routine)
      confirm_view_video_instruction(message, routine)
    end

    def send_exercise_information(message, routine)
      exercise = routine.exercise
      message.reply(text: "Your next exercise is #{ exercise.name }")
      message.reply(
        attachment: {
          type: 'image',
          payload: { url: exercise.picture }
        }
      )
      message.reply(text: "Set: #{ routine.set }. Reps: #{ routine.repetition }")
      message.reply(text: "Purpose: #{ exercise.purpose }")
    end

    def confirm_view_video_instruction(message, routine)
      message.reply({
        text: 'Would you want to see an instruction video for this exercise?',
        quick_replies: [QUICK_REPLIES[:yes], QUICK_REPLIES[:no]]
      })

      next_command(message.sender['id'], :handle_view_video_instruction, [routine])
    end

    def handle_view_video_instruction(message, routine)
      if message.quick_reply == 'YES'
        message.reply(text: 'Click the link below.')
        message.reply(text: routine.exercise.video)
      end

      confirm_start_exercise(message, routine)
    end

    def confirm_start_exercise(message, routine)
      message.reply({
        text: 'Would you like to start the exercise?',
        quick_replies: [QUICK_REPLIES[:start], QUICK_REPLIES[:skip]]
      })

      next_command(message.sender['id'], :handle_start_exercise, [routine])
    end

    def handle_start_exercise(message, routine)
      if message.quick_reply == 'START'
        confirm_exercise_done(message, routine)
      else
        PerformedRoutine.create(
          workout_session: conversation_stack[message.sender['id']].workout_session,
          routine: routine,
          status: PerformedRoutine::STATUS[:skipped]
        )
        check_for_next_routine(message, routine)
      end
    end

    def confirm_exercise_done(message, routine)
      message.reply({
        text: 'Kindly notify me when you are done',
        quick_replies: [QUICK_REPLIES[:done]]
      })

      next_command(message.sender['id'], :handle_exercise_done, [routine])
    end

    def handle_exercise_done(message, routine)
      if message.quick_reply == 'DONE'
        PerformedRoutine.create(
          workout_session: conversation_stack[message.sender['id']].workout_session,
          routine: routine,
          status: PerformedRoutine::STATUS[:done]
        )
        check_for_next_routine(message, routine)
      else
        end_conversation(message.sender['id'])
      end
    end

    def check_for_next_routine(message, routine)
      next_routine = routine.next_routine
      if next_routine.present?
        confirm_proceed_to_next_exercise(message, next_routine)
      else
        end_conversation(message.sender['id']) do
          conversation_stack[message.sender['id']].workout_session.update(status: WorkoutSession::STATUS[:complete])
          message.reply(text: 'Congratulations! You just completed your first exercise.')
        end
      end
    end

    def confirm_proceed_to_next_exercise(message, routine)
      message.reply({
        text: "Are you ready for the next exercise -- #{ routine.exercise.name }",
        quick_replies: [QUICK_REPLIES[:yes], QUICK_REPLIES[:no]]
      })

      next_command(message.sender['id'], :handle_proceed_to_next_exercise, [routine])
    end

    def handle_proceed_to_next_exercise(message, routine)
      if message.quick_reply == 'YES'
        initiate_exercise(message, routine)
      else
        confirm_stop_workout_session(message, routine)
      end
    end

    def confirm_stop_workout_session(message, routine)
      message.reply({
        text: "Do you want to stop the workout?",
        quick_replies: [QUICK_REPLIES[:yes], QUICK_REPLIES[:no]]
      })

      next_command(message.sender['id'], :handle_stop_workout_session, [routine])
    end

    def handle_stop_workout_session(message, routine)
      if message.quick_reply == 'YES'
        end_conversation(message.sender['id']) do
          message.reply(text: 'Goodbye! You can always start from where you left off.')
        end
      else
        initiate_exercise(message, routine)
      end
    end

    def end_conversation(sender_id)
      yield if block_given?
      ConversationStack.remove(sender_id)
      listen
    end

    def next_command(sender_id, command, args = [])
      conversation_stack[sender_id].next_command(command, args)
      listen
    end
  end

end

ExerciseBot.listen
