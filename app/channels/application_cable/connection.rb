module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :uuid

    def initialize
      @players = []
    end

    def connect
      self.uuid = SecureRandom.uuid

      REDIS.sadd('players_online', uuid)
      @players << uuid
      notify_players
    end

    def disconnect
      REDIS.srem('players_online', uuid)
      notify_players
      @players.delete(uuid)

      if Game.opponent_for(self.uuid)
        Game.opponent_disconnected(self.uuid)
      end
    end

    def receive(websocket_message)
      send_async :dispatch_websocket_message, websocket_message
      puts "!!!DEBUG #{websocket_message}"
    end

    def notify_players
      # players_online = REDIS.smembers('players_online')
      @players.each do |player|
        ActionCable.server.broadcast "action_cable/#{player}", {title: 'players_online', message: @players.size}
      end
    end
  end
end
