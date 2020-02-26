class Room < ApplicationRecord
  has_many :room_messages, dependent: :destroy,
                           inverse_of: :room

  def test_byebug
    puts "testing byebug"
    require 'byebug'; byebug
    puts "tested byebug"
  end
end
