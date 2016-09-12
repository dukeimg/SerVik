# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "player_#{uuid}"
    Seek.create(uuid)
  end

  def unsubscribed
    Seek.remove(uuid)
    Game.opponent_disconnected(uuid)
  end

  def set_code(data)
    Game.set_code(uuid, data)
  end

  def make_turn(data)
    Game.turn(uuid, data)
  end
end
