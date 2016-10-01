module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :uuid

    def connect
      self.uuid = SecureRandom.uuid

      REDIS.sadd('players_online', uuid)
      transmit({'title': 'players_online', 'message': ActionCable.server.connections.size + 1})
      notify_players
    end

    def disconnect
      notify_players

      if Game.opponent_for(self.uuid)
        Game.opponent_disconnected(self.uuid)
      end
    end

    def receive(websocket_message)
      send_async :dispatch_websocket_message, websocket_message
      puts "!!!DEBUG #{websocket_message}"
    end

    def notify_players
      ActionCable.server.connections.each do |connection|
        puts connection
        connection.transmit({'title': 'players_online', 'message': ActionCable.server.connections.size})
      end
    end
  end
end
