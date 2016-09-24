# Главное отличие бытрой игры в том, что в ней нет изменяемых правил, а значит и нет переменной params
class QuickGame < Game
  def initialize(uuid_1, uuid_2)
    @player_1 = uuid_1
    @player_2 = uuid_2

    set_opponents(@player_1, @player_2)
    send_greet_messages(@player_1, @player_2)
  end
end