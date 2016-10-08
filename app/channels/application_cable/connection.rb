module ApplicationCable
  class Connection < ActionCable::Connection::Base
    include GamesHelper

    identified_by :uuid

    def connect
      self.uuid = SecureRandom.uuid

      msg = {"identifier":"{\"channel\":\"NotificationsChannel\"}","message":{"title":"players_online","message":ActionCable.server.connections.size + 1}}
      transmit(msg)
      send_rooms_data(msg)
      send_players_online(ActionCable.server.connections.size + 1)
    end

    def disconnect
      msg = {"identifier":"{\"channel\":\"NotificationsChannel\"}","message":{"title":"players_online","message":ActionCable.server.connections.size}}
      send_rooms_data(msg)
      send_players_online(ActionCable.server.connections.size)
      if Game.opponent_for(self.uuid)
        Game.opponent_disconnected(self.uuid)
      end
    end

    def send_players_online(msg)
      ActionCable.server.connections.each do |connection|
        connection.transmit({"identifier":"{\"channel\":\"NotificationsChannel\"}","message":{"title":"players_online","message":msg}})
      end
    end

    def receive(websocket_message)
      send_async :dispatch_websocket_message, websocket_message
      puts "!!!DEBUG #{websocket_message}"
    end
  end
end
