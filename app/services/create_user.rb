class CreateUser

  def initialize(sender_id)
    @sender_id = sender_id
  end

  def self.call(*args)
    new(*args).call
  end

  def call
    {
      new_user: user.nil?,
      user: find_or_create
    }
  end

private

  attr_reader :sender_id

  def find_or_create
    user.nil? ? User.create(sender_id: sender_id) : user
  end

  def user
    @user ||= User.find_by(sender_id: sender_id)
  end
end
