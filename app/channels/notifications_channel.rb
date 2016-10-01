# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    transmit({'title': 'players_online', 'message': ActionCable.server.connections.size})
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
