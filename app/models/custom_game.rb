class CustomGame < Game
  def initialize(uuid_1, uuid_2, params)
    @player_1, @player_2 = [uuid_1, uuid_2].shuffle
    @params = params

    set_opponents(@player_1, @player_2)
    send_greet_messages(@player_1, @player_2)
  end
end