require 'facebook/messenger'

include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

Bot.on :message do |message|
  begin
    if CreateUser.new(message.sender['id']).call[:new_user]
      message.reply(text: "Your account has been created successully")
    else
      message.reply(text: "Your account could not be created. It already exists!")
    end

    message.reply({
      text: 'Hi Human! Would you like to start a workout session?',
      quick_replies: [
        {
          content_type: 'text',
          title: 'Yes',
          payload: 'YES'
        },
        {
          content_type: 'text',
          title: 'No',
          payload: 'NO'
        }
      ]
    })

    Bot.on :message do |message|
      if message.quick_reply == 'YES'
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
          workout_id = message.quick_reply
          first_routine = Workout.find(workout_id).routines.order(:position).first
          first_exercise = first_routine.exercise
          message.reply(text: "Your first exercise is #{ first_exercise.name }. #{ first_exercise.picture }")
          message.reply(
            attachment: {
              type: 'image',
              payload: { url: first_exercise.picture }
            }
          )
          message.reply(text: "Purpose: #{ first_exercise.purpose }")
          message.reply({
            text: 'Would you want to see an instruction video for this exercise?',
            quick_replies: [
              {
                content_type: 'text',
                title: 'Yes',
                payload: 'YES'
              },
              {
                content_type: 'text',
                title: 'No',
                payload: 'NO'
              }
            ]
          })

          Bot.on :message do |message|
            if message.quick_reply == 'YES'
              message.reply(text: 'Click the link below.')
              message.reply(text: first_exercise.video)
            end

            message.reply({
              text: 'Are you Ready?',
              quick_replies: [
                {
                  content_type: 'text',
                  title: 'Yes',
                  payload: 'YES'
                },
                {
                  content_type: 'text',
                  title: 'No',
                  payload: 'NO'
                }
              ]
            })

            Bot.on :message do |message|
              if message.quick_reply == 'YES'
                message.reply(text: 'Here are the details of your exercise.')
                message.reply(text: "Set: #{ first_routine.set }. Reps: #{ first_routine.repetition }")
                message.reply({
                  text: 'Kinly notify me when you are done',
                  quick_replies: [
                    {
                      content_type: 'text',
                      title: 'Done',
                      payload: 'DONE'
                    },
                  ]
                })

                Bot.on :message do |message|
                  if message.quick_reply == 'DONE'
                    message.reply(text: 'Congratulations! You just completed your first exercise.')
                  end
                end
              end
            end
          end
        end
      else
        message.reply(text: 'Alright! But you can come back whenever you feel like working out.')
      end
    end

  rescue => exception
    p exception.message
    message.reply(text: 'Something went wrong. Please start again')
  end
end
