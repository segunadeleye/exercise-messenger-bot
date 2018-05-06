require 'facebook/messenger'

include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

Bot.on :message do |message|
  if CreateUser.new(message.sender['id']).call[:new_user]
    message.reply(text: "Your account has been created successully")
  else
    message.reply(text: "Your account could not be created. It already exists!")
  end
end
