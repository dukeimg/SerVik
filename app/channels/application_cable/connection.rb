module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :uuid

    def connect
      self.uuid = SecureRandom.uuid

      players_online = ActionCable.server.connections.size
      transmit({"title": "players_online", "message": players_online})
      puts "Игроков в сети #{players_online}" # debug
    end

    def disconnect
      players_online = ActionCable.server.connections.size
      transmit({"title": "players_online", "message": players_online})
      puts "Игроков в сети #{players_online}" # debug
    end
  end
end
