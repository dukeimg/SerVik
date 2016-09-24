class VirtualGame
  def self.init(uuid)
    ActionCable.server.broadcast "player_#{uuid}", {action: "waiting_for_code"}
  end

  def self.set_code(uuid, data)
    REDIS.set("code_for:#{uuid}", data['msg'])
    rand_code = Random.rand(1000..9999).to_s
    t = 4 - rand_code.size
    code = '0' * t << rand_code
    REDIS.set("virtual_opponent_code_for:#{uuid}", code)
    self.start(uuid)
  end

  def self.start(uuid)
    ActionCable.server.broadcast "player_#{uuid}", {action: "game_start", is_your_turn:1}
  end

  def self.opponent_disconnected(uuid)
    REDIS.del("code_for:#{uuid}")
  end

  def self.turn(uuid, data)
    guess = data['msg']
    answer = REDIS.get("virtual_opponent_code_for:#{uuid}")

    if guess == answer
      end_game(uuid, nil, 'code_is_guessed')
    else
      response = self.crypt(guess, answer)
      ActionCable.server.broadcast "player_#{uuid}", {action: 'turn', msg: response, is_your_turn:0, code: guess}
      sleep(1)
      ai_guess = Random.rand(0..9999)
      answer = REDIS.get("code_for:#{uuid}")
      if ai_guess == answer.to_i
        end_game(nil, uuid, 'code_is_guessed')
      else
        ai_guess = ai_guess.to_s
        t = 4 - ai_guess.size
        code = '0' * t << ai_guess
        response = self.crypt(ai_guess, answer)
        ActionCable.server.broadcast "player_#{uuid}", {action: 'turn', code: code, is_your_turn:1, msg: response}
      end
    end
  end

  # Конец игры
  def self.end_game(winner, loser, reason)
    if loser
      ActionCable.server.broadcast "player_#{loser}", {action: "end_game", win:0, opponent_code: get_code(winner), reason: reason}
    end
    ActionCable.server.broadcast "player_#{winner}", {action: "end_game", win:1,  opponent_code: get_code(loser), reason: reason}
    self.clear_redis(winner)
  end

  # Игрок сдался. Оппонент получает об этом уведомление. База данных очищается
  def self.forfeit(uuid)

  end

  private

  def self.crypt(guess, answer)
    guess_arr = guess.split('')
    answer_arr = answer.split('')
    a1, a2 = [guess_arr, answer_arr].map(&:dup) # to keep originals intact
    a = loop.inject([]) do |memo|
      break memo if a1.empty?
      memo << (a2.delete_at(a2.index a1.pop) rescue nil)
    end.compact.size

    b = (guess_arr.zip(answer_arr).map { |x, y| x == y }).inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}[true]
    "#{a}:#{b}"
  end

  def self.clear_redis(uuid)
    REDIS.del("code_for:#{uuid}")
    REDIS.del("virtual_opponent_code_for:#{uuid}")
  end
end