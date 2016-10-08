module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :uuid

    def connect
      self.uuid = SecureRandom.uuid

      msg = {"identifier":"{\"channel\":\"NotificationsChannel\"}","message":{"title":"players_online","message":ActionCable.server.connections.size + 1}}
      transmit(msg)
      GamesHelper.send_rooms_data
    end

    def disconnect
      msg = {"identifier":"{\"channel\":\"NotificationsChannel\"}","message":{"title":"players_online","message":ActionCable.server.connections.size}}
      GamesHelper.send_rooms_data

      if Game.opponent_for(self.uuid)
        Game.opponent_disconnected(self.uuid)
      end
    end

    def receive(websocket_message)
      send_async :dispatch_websocket_message, websocket_message
      puts "!!!DEBUG #{websocket_message}"
    end
  end
end
