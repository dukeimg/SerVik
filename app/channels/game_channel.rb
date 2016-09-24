# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "player_#{uuid}"
    ActionCable.server.broadcast('game', ActionCable.server.connections.size)
  end

  def unsubscribed
    Seek.remove(uuid)
    Game.opponent_disconnected(uuid)
    ActionCable.server.broadcast('game', ActionCable.server.connections.size)
  end

  def set_code(data)
    Game.set_code(uuid, data)
  end

  def make_turn(data)
    Game.turn(uuid, data)
  end

  def forfeit(data)
    Game.forfeit(uuid)
  end

  def seek(data)
    ActionCable.server.broadcast "player_#{uuid}", {action: "seek_started"}
    Seek.new(uuid, data)
  end

  def v_set_code(data)
    VirtualGame.set_code(uuid, data)
  end

  def v_make_turn(data)
    VirtualGame.turn(uuid, data)
  end

  def virtual_game
    VirtualGame.init(uuid)
  end
end
