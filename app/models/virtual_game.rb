class VirtualGame < Game
  def self.init(uuid)
    ActionCable.server.broadcast "player_#{uuid}", {action: "waiting_for_code"}
  end

  def self.set_code(uuid, data)
    REDIS.set("code_for:#{uuid}", data['msg'])
    rand_code = Random.rand(1000..9999).to_s
    t = 4 - rand_code.size
    code = '0' * t << rand_code
    REDIS.set("virtual_opponent_code_for:#{uuid}", code)
    puts "AI_CODE #{code}"
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
      response_arr = crypt(guess, answer)
      response = "#{response_arr[0]}:#{response_arr[1]}"
      ActionCable.server.broadcast "player_#{uuid}", {action: 'turn', msg: response, is_your_turn:0, code: guess}
      s = REDIS.get("codes_for:#{uuid}")
      answer = REDIS.get("code_for:#{uuid}")
      if s
        s = JSON.parse s
        # Второй и более ходы
        # В этом случае мы работаем с тем множеством возможных решений, что получили из предыдущего хода
        ai_guess = s.shuffle.pop
        if ai_guess == answer
          end_game(nil, uuid, 'code_is_guessed')
        else
          t = 4 - ai_guess.size
          code = '0' * t << ai_guess
          response_arr = crypt(ai_guess, answer)
          response = "#{response_arr[0]}:#{response_arr[1]}"
          ActionCable.server.broadcast "player_#{uuid}", {action: 'turn', code: code, is_your_turn:1, msg: response}
          s.reject! {|x| crypt(x, ai_guess) == response_arr}
          REDIS.set("codes_for:#{uuid}", s)
          puts "Множество решений: #{s.size}"
        end
      else
        # Случай перевого хода. Здесь создаётся множество возможных решений.
        s = Array(0..9999)
        s.each_with_index do |i, x|
          x = x.to_s
          t = 4 - x.size
          s[i] = '0' * t << x
        end
        # Далее совершается случайный ход
        ai_guess = Random.rand(0..9999)
        if ai_guess == answer.to_i
          end_game(nil, uuid, 'code_is_guessed')
        else
          # На основе полученных данных сокращаем множество
          ai_guess = ai_guess.to_s
          t = 4 - ai_guess.size
          code = '0' * t << ai_guess
          response_arr = crypt(ai_guess, answer)
          response = "#{response_arr[0]}:#{response_arr[1]}"
          ActionCable.server.broadcast "player_#{uuid}", {action: 'turn', code: code, is_your_turn:1, msg: response}
          s.reject! {|x| crypt(x, ai_guess) == response_arr}
          REDIS.set("codes_for:#{uuid}", s)
        end
      end
    end
  end

  # Конец игры
  def self.end_game(winner, loser, reason)
    if loser
      ai_code = REDIS.get("virtual_opponent_code_for:#{loser}") || nil
      ActionCable.server.broadcast "player_#{loser}", {action: "end_game", win:0, opponent_code: ai_code, reason: reason}
    else
      ai_code = REDIS.get("virtual_opponent_code_for:#{winner}") || nil
      ActionCable.server.broadcast "player_#{winner}", {action: "end_game", win:1,  opponent_code: ai_code, reason: reason}
    end
    self.clear_redis(winner)
  end

  private

  def self.clear_redis(uuid)
    REDIS.del("code_for:#{uuid}")
    REDIS.del("codes_for:#{uuid}")
    REDIS.del("virtual_opponent_code_for:#{uuid}")
  end
end