class Seek
  def initialize(uuid, data)
    filter = data['filter']
    if filter
      self.init_seek_with_filters(uuid, data)
    else
      self.init_quick_game(uuid)
    end
  end

  class << self
    include GamesHelper

    def remove(uuid)
      REDIS.hdel("seeks", uuid)
      REDIS.srem('q_seeks', uuid)
    end

    def clear_all
      REDIS.del("seeks")
      REDIS.del('q_seeks')
    end

    def get_rooms
      h_seeks = REDIS.hgetall("seeks")
      if h_seeks
        seeks = []
        h_seeks.each_with_index {|(k,v), i| seeks[i] = (JSON.parse v.gsub('=>', ':')); seeks[i]['uuid'] = k}
        msg = {title: 'rooms', data: seeks.to_json}
      else
        msg = {title: 'rooms', data: {}}
      end
      msg
    end

    def connect(uuid, data)
      opponent_uuid = data['uuid']
      opponent = REDIS.hget('seeks', opponent_uuid)
      if opponent
        opponent = eval(opponent)
        opponent.delete('title_game')
        active_filters = opponent.select {|key, value| value if opponent[key] != 0}
        REDIS.hdel('seeks', opponent_uuid)
        CustomGame.new(uuid, opponent_uuid, active_filters)
      else
        ActionCable.server.broadcast "player_#{uuid}", {action: 'connection_error', reason: 'room_does_not_exist'}
      end
      send_rooms_data(Seek.get_rooms)
    end

    def init_quick_game(uuid)
      if opponent = REDIS.spop("q_seeks")
        QuickGame.new(uuid, opponent)
      else
        REDIS.sadd("q_seeks", uuid)
      end
    end

    def init_seek_with_filters(uuid, data)
      filter = data['filter']
      active_filters = filter.select {|key, value| value if filter[key] != 0} || ''

      # Temporal debug messages
      puts "data: #{data}"
      puts "filter: #{filter}"

      if d = REDIS.hscan_each("seeks").detect {|u, d| d == (d || active_filters)}
        if d[0] == uuid
          REDIS.hset("seeks", uuid, filter)
        else
          REDIS.hdel('seeks', d[0])
          CustomGame.new(uuid, d[0], active_filters || d[1])
        end
      else
        REDIS.hset("seeks", uuid, filter)
      end
      send_rooms_data(Seek.get_rooms)
    end
  end
end