module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :uuid

    def connect
      self.uuid = SecureRandom.uuid
      ActionCable.server.broadcast self, {msg: 'You have been subscribed'}
    end
  end
end
