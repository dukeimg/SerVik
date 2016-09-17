# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "player_#{uuid}"
  end

  def unsubscribed
    Seek.remove(uuid)
    Game.opponent_disconnected(uuid)
  end

  def set_code(data)
    if data.virtual
      VirtualGame.set_code(uuid, data)
    else
      Game.set_code(uuid, data)
    end
  end

  def make_turn(data)
    if data.virtual
      VirtualGame.turn(uuid, data)
    else
      Game.turn(uuid, data)
    end
  end

  def seek(data)
    Seek.create(uuid, data)
  end

  def virtual_game
    VirtualGame.init(uuid)
  end
end
