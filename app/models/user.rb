class User < ApplicationRecord
  validates :sender_id, presence: true
end
