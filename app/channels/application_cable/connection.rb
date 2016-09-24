module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :uuid

    def connect
      self.uuid = SecureRandom.uuid
      transmit "{title: 'Игроков в сети', msg: ActionCable.server.connections.size}"
    end

    def disconnect
      transmit "{title: 'Игроков в сети', msg: ActionCable.server.connections.size}"
    end
  end
end
