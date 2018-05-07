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
    }
  }

  class << self
    def listen
      Bot.on :message do |message|
        handle_initial_message(message)
        ask_for_workout_start(message)
      end
    end

    def handle_initial_message(message)
      user = get_user(message.sender['id'])
      if user[:new_user]
        message.reply(text: "Your account has been created successully")
      else
        message.reply(text: "Your account could not be created. It already exists!")
      end
    end

    def get_user(sender_id)
      CreateUser.new(sender_id).call
    end

    def ask_for_workout_start(message)
      message.reply({
        text: 'Hi Human! Would you like to start a workout session?',
        quick_replies: [QUICK_REPLIES[:yes], QUICK_REPLIES[:no]]
      })

      Bot.on :message do |message|
        if message.quick_reply == 'YES'
          select_workout(message)
        else
          message.reply(text: 'Alright! But you can come back whenever you feel like working out.')
          listen
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
        first_routine = Workout.find(message.quick_reply).routines.order(:position).first
        inform_about_exercise(message, first_routine)
        ask_for_instructional_video(message, first_routine)
      end
    end

    def inform_about_exercise(message, routine)
      exercise = routine.exercise
      message.reply(text: "Your first exercise is #{ exercise.name }. #{ exercise.picture }")
      message.reply(
        attachment: {
          type: 'image',
          payload: { url: exercise.picture }
        }
      )
      message.reply(text: "Purpose: #{ exercise.purpose }")
    end

    def ask_for_instructional_video(message, routine)
      message.reply({
        text: 'Would you want to see an instruction video for this exercise?',
        quick_replies: [QUICK_REPLIES[:yes], QUICK_REPLIES[:no]]
      })

      Bot.on :message do |message|
        if message.quick_reply == 'YES'
          message.reply(text: 'Click the link below.')
          message.reply(text: routine.exercise.video)
        end

        ask_ready_to_start(message, routine)
      end
    end

    def ask_ready_to_start(message, routine)
      message.reply({
        text: 'Are you Ready?',
        quick_replies: [QUICK_REPLIES[:yes], QUICK_REPLIES[:no]]
      })

      Bot.on :message do |message|
        if message.quick_reply == 'YES'
          message.reply(text: 'Here are the details of your exercise.')
          message.reply(text: "Set: #{ routine.set }. Reps: #{ routine.repetition }")
          notify_when_done(message)
        else
          message.reply(text: 'Alright! But you can come back whenever you feel like working out.')
          listen
        end
      end
    end

    def notify_when_done(message)
      message.reply({
        text: 'Kinly notify me when you are done',
        quick_replies: [QUICK_REPLIES[:done]]
      })

      Bot.on :message do |message|
        if message.quick_reply == 'DONE'
          message.reply(text: 'Congratulations! You just completed your first exercise.')
        end
        listen
      end
    end
  end

end

ExerciseBot.listen
