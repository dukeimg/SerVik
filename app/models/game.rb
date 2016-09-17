class Game
  def self.init(uuid1, uuid2)
    @player_1, @player_2 = [uuid1, uuid2].shuffle

    REDIS.set("opponent_for:#{@player_1}", @player_2)
    REDIS.set("opponent_for:#{@player_2}", @player_1)

    ActionCable.server.broadcast "player_#{@player_1}", {action: "waiting_for_code"}
    ActionCable.server.broadcast "player_#{@player_2}", {action: "waiting_for_code"}
  end
  
  def self.set_code(uuid, data)
    REDIS.set("code_for:#{uuid}", data['msg'])
    if get_code(opponent_for(uuid))
      start
    end
  end

  def self.start
    ActionCable.server.broadcast "player_#{@player_1}", {action: "game_start", is_your_turn:1}
    ActionCable.server.broadcast "player_#{@player_2}", {action: "game_start", is_your_turn:0}
  end

  def self.end_game(winner)
    loser = opponent_for(winner)
    ActionCable.server.broadcast "player_#{winner}", {action: "end_game", win:1}
    ActionCable.server.broadcast "player_#{loser}", {action: "end_game", win:0, opponent_code: get_code(winner)}
    self.clear_redis(winner, loser)
  end

  def self.forfeit(uuid)
    if winner = opponent_for(uuid)
      ActionCable.server.broadcast "player_#{winner}", {action: "opponent_forfeits"}
    end
    self.clear_redis(uuid, winner)
  end

  def self.opponent_disconnected(uuid)
    if winner = opponent_for(uuid)
      ActionCable.server.broadcast "player_#{winner}", {action: "opponent_disconnected"}
      self.clear_redis(uuid, winner)
    else
      self.clear_redis(uuid, nil)
    end
  end

  def self.turn(uuid, data)
    opponent = opponent_for(uuid)
    guess = data['msg']
    answer = get_code(opponent)

    if guess == answer
      end_game(uuid)
      response = '4:4'
    else
      guess_arr = guess.split('')
      answer_arr = answer.split('')
      a = (guess_arr & answer_arr).size
      b = (guess_arr.zip(answer_arr).map { |x, y| x == y }).inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}[true]
      response = "#{a}:#{b}"
      ActionCable.server.broadcast "player_#{opponent}", {action: 'turn', code: guess, is_your_turn:1}
      ActionCable.server.broadcast "player_#{uuid}", {action: 'turn', msg: response, is_your_turn:0}
    end
    response # Для теста
  end

  private

  def self.opponent_for(uuid)
    REDIS.get("opponent_for:#{uuid}")
  end

  def self.get_code(uuid)
    return '2751' if Rails.env.test?
    REDIS.get("code_for:#{uuid}")
  end

  def self.clear_redis(pl_1, pl_2)
    REDIS.del("opponent_for:#{pl_1}")
    REDIS.del("opponent_for:#{pl_2}")
    REDIS.del("code_for:#{pl_1}")
    REDIS.del("code_for:#{pl_2}")
  end
end