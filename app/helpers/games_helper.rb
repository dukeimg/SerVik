module GamesHelper
  def create_mock_room
    filter = {"mode"=>"tb", "time_limit"=>0, "turn_limit"=>0, "turn_time_limit"=>0, "title_game"=>"dummy"}
    REDIS.hdel('seeks', 'fake_uuid')
    REDIS.hset("seeks", 'fake_uuid', filter)
  end

  def send_rooms_data(msg)
    ActionCable.server.connections.each do |connection|
      connection.transmit(msg)
    end
  end
end
