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
      puts "Игроков в сети #{players_online}" # debug
    end

    def disconnect
      players_online = REDIS.get('players_online').to_i
      players_online -= 1
      REDIS.set('players_online', players_online)
      transmit({'title': 'players_online', 'message': players_online})
      puts "Игроков в сети #{players_online}" # debug

      if Game.opponent_for(self.uuid)
        Game.opponent_disconnected(uuid)
      end
    end
  end
end
