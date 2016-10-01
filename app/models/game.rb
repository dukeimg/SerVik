# Основная логика игры сосредоточена в этой модели
class Game
  # Задаём код перед началом игры
  def self.set_code(uuid, data)
    REDIS.set("code_for:#{uuid}", data['msg'])
    if get_code(opponent_for(uuid))
      start(uuid, opponent_for(uuid))
    end
  end

  # Старт игры
  def self.start(p_1, p_2)
    ActionCable.server.broadcast "player_#{p_1}", {action: "game_start", is_your_turn:1}
    ActionCable.server.broadcast "player_#{p_2}", {action: "game_start", is_your_turn:0}
  end

  # Конец игры
  def self.end_game(winner, loser, reason)
    if loser
      ActionCable.server.broadcast "player_#{loser}", {action: "end_game", win:0, opponent_code: get_code(winner), reason: reason}
    end
    ActionCable.server.broadcast "player_#{winner}", {action: "end_game", win:1,  opponent_code: get_code(loser), reason: reason}
    GameChannel.unsubscribe_from_channel(winner)
    GameChannel.unsubscribe_from_channel(loser)
    self.clear_redis(winner, loser)
  end

  # Игрок сдался. Оппонент получает об этом уведомление. База данных очищается
  def self.forfeit(uuid)
    if winner = opponent_for(uuid)
      end_game(winner, uuid, 'opponent_forfeits')
    end
    self.clear_redis(uuid, winner)
  end

  # Разрыв соединение. Если имееется оппонент, то ему присваеивается победа
  def self.opponent_disconnected(uuid)
    if winner = opponent_for(uuid)
      self.end_game(winner, nil, 'opponent_disconnected')
      self.clear_redis(uuid, winner)
    else
      self.clear_redis(uuid, nil)
    end
  end

  # Выполнение хода
  def self.turn(uuid, data)
    opponent = opponent_for(uuid)
    guess = data['msg']
    answer = get_code(opponent)

    if guess == answer
      end_game(uuid, opponent, 'code_is_guessed')
    else
      response = crypt(guess, answer)
      ActionCable.server.broadcast "player_#{opponent}", {action: 'turn', msg: response, is_your_turn:1, code: guess}
      ActionCable.server.broadcast "player_#{uuid}", {action: 'turn', msg: response, is_your_turn:0, code: guess}
    end
  end

  private

  # Идентификация оппонента
  def self.opponent_for(uuid)
    REDIS.get("opponent_for:#{uuid}")
  end

  # Получаение кода
  def self.get_code(uuid)
    return '2751' if Rails.env.test?
    REDIS.get("code_for:#{uuid}")
  end

  # Очистка REDIS
  def self.clear_redis(pl_1, pl_2)
    REDIS.del("opponent_for:#{pl_1}")
    REDIS.del("opponent_for:#{pl_2}")
    REDIS.del("code_for:#{pl_1}")
    REDIS.del("code_for:#{pl_2}")
  end

  # Алгоритм анализа полученного от игрока кода
  def self.crypt(guess, answer)
    guess_arr = guess.split('')
    answer_arr = answer.split('')
    a1, a2 = [guess_arr, answer_arr].map(&:dup) # чтобы не трогать оригиналы
    a = loop.inject([]) do |memo|
      break memo if a1.empty?
      memo << (a2.delete_at(a2.index a1.pop) rescue nil)
    end.compact.size # удаляем все nil и определяем длину

    b = (guess_arr.zip(answer_arr).map { |x, y| x == y }).inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}[true]
    "#{a}:#{b}"
  end

  # Отправляем сообщение об ожидании ввода кода
  def send_greet_messages(p_1, p_2)
    ActionCable.server.broadcast "player_#{p_1}", {action: "waiting_for_code"}
    ActionCable.server.broadcast "player_#{p_2}", {action: "waiting_for_code"}
  end

  # Задаём оппонентов
  def set_opponents(p_1, p_2)
    REDIS.set("opponent_for:#{p_1}", p_2)
    REDIS.set("opponent_for:#{p_2}", p_1)
  end
end