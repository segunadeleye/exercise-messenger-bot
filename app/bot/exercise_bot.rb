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
      Bot.on :message do |message|
        handle_initial_message(message)
      end
    end

    def handle_initial_message(message)
      @user = CreateUser.call(message.sender['id'])

      if @user[:new_user]
        message.reply(text: 'Welcome Padwan! Your account has been created.')
        confirm_start_workout(message)
      else
        message.reply(text: 'Welcome Back Jedi! Good to have you back')
        check_incomplete_workout(message)
      end
    end

    def check_incomplete_workout(message)
      if user.has_pending_workout_session?
        confirm_continue_workout(message)
      else
        confirm_start_workout(message)
      end
    end

    def user
      @user[:user]
    end

    def confirm_continue_workout(message)
      message.reply({
        text: 'Would you like to continue from where you stopped?',
        quick_replies: [QUICK_REPLIES[:yes], QUICK_REPLIES[:no]]
      })

      Bot.on :message do |message|
        @workout_session = user.workout_sessions.pending.first

        if message.quick_reply == 'YES'
          message.reply(text: "Let's get started!!!")
          initiate_exercise(message, GetPendingRoutine.call(@workout_session))
        else
          @workout_session.update(status: WorkoutSession::STATUS[:incomplete])
          confirm_start_workout(message)
        end
      end
    end

    def confirm_start_workout(message)
      message.reply({
        text: 'Hi Human! Would you like to start a workout session?',
        quick_replies: [QUICK_REPLIES[:yes], QUICK_REPLIES[:no]]
      })

      Bot.on :message do |message|
        if message.quick_reply == 'YES'
          select_workout(message)
        else
          end_conversation { message.reply(text: 'Alright! But you can come back whenever you feel like working out.') }
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

      Bot.on :message do |message|
        @workout_session = WorkoutSession.create(user: user, workout_id: message.quick_reply)
        initiate_exercise(message, Workout.find(message.quick_reply).routines.first)
      end
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

      Bot.on :message do |message|
        if message.quick_reply == 'YES'
          message.reply(text: 'Click the link below.')
          message.reply(text: routine.exercise.video)
        end

        confirm_start_exercise(message, routine)
      end
    end

    def confirm_start_exercise(message, routine)
      message.reply({
        text: 'Would you like to start the exercise?',
        quick_replies: [QUICK_REPLIES[:start], QUICK_REPLIES[:skip]]
      })

      Bot.on :message do |message|
        if message.quick_reply == 'START'
          confirm_exercise_done(message, routine)
        else
          PerformedRoutine.create(workout_session: @workout_session, routine: routine, status: PerformedRoutine::STATUS[:skipped])
          check_for_next_routine(message, routine)
        end
      end
    end

    def confirm_exercise_done(message, routine)
      message.reply({
        text: 'Kindly notify me when you are done',
        quick_replies: [QUICK_REPLIES[:done]]
      })

      Bot.on :message do |message|
        if message.quick_reply == 'DONE'
          PerformedRoutine.create(workout_session: @workout_session, routine: routine, status: PerformedRoutine::STATUS[:done])
          check_for_next_routine(message, routine)
        else
          end_conversation
        end
      end
    end

    def check_for_next_routine(message, routine)
      next_routine = routine.next_routine
      if next_routine.present?
        confirm_proceed_to_next_exercise(message, next_routine)
      else
        end_conversation do
          @workout_session.update(status: WorkoutSession::STATUS[:complete])
          message.reply(text: 'Congratulations! You just completed your first exercise.')
        end
      end
    end

    def confirm_proceed_to_next_exercise(message, routine)
      message.reply({
        text: "Are you ready for the next exercise -- #{ routine.exercise.name }",
        quick_replies: [QUICK_REPLIES[:yes], QUICK_REPLIES[:no]]
      })

      Bot.on :message do |message|
        if message.quick_reply == 'YES'
          initiate_exercise(message, routine)
        else
          confirm_stop_workout_session(message, routine)
        end
      end
    end

    def confirm_stop_workout_session(message, routine)
      message.reply({
        text: "Do you want to stop the workout?",
        quick_replies: [QUICK_REPLIES[:yes], QUICK_REPLIES[:no]]
      })

      Bot.on :message do |message|
        if message.quick_reply == 'YES'
          end_conversation { message.reply(text: 'Goodbye! You can always start from where you left off.') }
        else
          initiate_exercise(message, routine)
        end
      end
    end

    def end_conversation
      yield if block_given?
      listen
    end
  end

end

ExerciseBot.listen
