# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "player_#{uuid}"
    # ActionCable.server.broadcast "player_#{uuid}", {action:'subscribed', uuid: "#{uuid}", msg: 'You have been subscribed'}
    Seek.create(uuid)
  end

  def unsubscribed
    Seek.remove(uuid)
  end
end
