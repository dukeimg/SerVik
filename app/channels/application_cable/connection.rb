module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :uuid

    def connect
      self.uuid = SecureRandom.uuid

      REDIS.sadd('players_online', uuid)
      players_online = REDIS.get('players_online').size
      players_online.each do |player|
        ActionCable.server.broadcast player, {title: 'players_online', message: players_online}
      end
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
