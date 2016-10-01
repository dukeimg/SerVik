module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :uuid

    def connect
      self.uuid = SecureRandom.uuid

      msg = {"identifier":"{\"channel\":\"NotificationsChannel\"}","message":{"title":"players_online","message":ActionCable.server.connections.size + 1}}
      transmit(msg)
      ActionCable.server.connections.each do |connection|
        connection.transmit(msg)
      end
    end

    def disconnect
      msg = {"identifier":"{\"channel\":\"NotificationsChannel\"}","message":{"title":"players_online","message":ActionCable.server.connections.size}}
      ActionCable.server.connections.each do |connection|
        connection.transmit(msg)
      end

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
