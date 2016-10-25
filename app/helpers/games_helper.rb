module GamesHelper
  def create_mock_room
    10.times do |n|
      f_1 = ['tb', 'rt'].shuffle.pop
      f_2 = [3, 5, 10].shuffle.pop
      f_3 = [5, 10, 20].shuffle.pop
      f_4 = [15, 30, 60].shuffle.pop
      name = ['Сергей', 'Витя', 'Дима', 'Андрей', 'Алина', 'Клара Ватсон', 'Таня', 'Шишка', 'Ляшка'].shuffle.pop
      filter = {"mode"=>f_1, "time_limit"=>f_2, "turn_limit"=>f_3, "turn_time_limit"=>f_4, "title_game"=>name}
      REDIS.hdel('seeks', "fake_uuid_#{n}")
      REDIS.hset("seeks", "fake_uuid_#{n}", filter)
    end
  end

  def create_mock_room_9000
    9000.times do |n|
      f_1 = ['tb', 'rt'].shuffle.pop
      f_2 = [3, 5, 10].shuffle.pop
      f_3 = [5, 10, 20].shuffle.pop
      f_4 = [15, 30, 60].shuffle.pop
      name = ['Сергей', 'Витя', 'Дима', 'Андрей', 'Алина', 'Клара Ватсон', 'Таня', 'Шишка', 'Ляшка'].shuffle.pop
      filter = {"mode"=>f_1, "time_limit"=>f_2, "turn_limit"=>f_3, "turn_time_limit"=>f_4, "title_game"=>name}
      REDIS.hdel('seeks', "fake_uuid_#{n}")
      REDIS.hset("seeks", "fake_uuid_#{n}", filter)
    end
  end

  def send_rooms_data(msg)
    ActionCable.server.connections.each do |connection|
      connection.transmit({"identifier":"{\"channel\":\"GameChannel\"}", "message":msg})
    end
  end
end
