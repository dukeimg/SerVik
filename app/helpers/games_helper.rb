module GamesHelper
  def create_mock_room
    filter = {"mode"=>"tb", "time_limit"=>0, "turn_limit"=>0, "turn_time_limit"=>0, "title_game"=>"dummy"}
    REDIS.hset("seeks", 'fake_uuid', filter)
  end
end
