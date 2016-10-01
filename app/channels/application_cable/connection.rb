module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :uuid

    def connect
      self.uuid = SecureRandom.uuid

      players_online = REDIS.get('players_online') || 0
      players_online = players_online.to_i
      players_online += 1
      REDIS.set('players_online', players_online)
      transmit({'title': 'players_online', 'message': players_online})
      send_async :dispatch_websocket_message, "{'title': 'players_online', 'message': #{players_online}}"
      puts "Игроков в сети #{players_online}" # debug
      puts subscriptions
      puts ActionCable.server.connections
    end

    def disconnect
      players_online = REDIS.get('players_online').to_i
      players_online -= 1
      REDIS.set('players_online', players_online)
      transmit({'title': 'players_online', 'message': players_online})
      puts "Игроков в сети #{players_online}" # debug

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
