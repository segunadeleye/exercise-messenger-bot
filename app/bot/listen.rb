require 'facebook/messenger'

include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

Bot.on :message do |message|
  message.reply(text: "Welcome to the home of your Personal Trainer! Hope you are pumped up for your workout sessions? I'm sure you are :)")
end
