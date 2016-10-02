class Seek
  def initialize(uuid, data)
    filter = data['filter']
    if filter
      init_seek_with_filters(uuid, data)
    else
      init_quick_game(uuid)
    end
  end

  def self.remove(uuid)
    REDIS.hdel("seeks", uuid)
    REDIS.srem('q_seeks', uuid)
  end

  def self.clear_all
    REDIS.del("seeks")
    REDIS.del('q_seeks')
  end

  private

  def init_quick_game(uuid)
    if opponent = REDIS.spop("q_seeks")
      QuickGame.new(uuid, opponent)
    else
      REDIS.sadd("q_seeks", uuid)
    end
  end

  def init_seek_with_filters(uuid, data)
    filter = data['filter']
    # active_filters = filter.select {|key, value| value if data[key] != 0} if data['filter'].exists? else ''
    active_filters = filter.select {|key, value| value if data[key] != 0}

    # Temporal debug messages
    puts "data: #{data}"
    puts "filter: #{filter}"

    if d = REDIS.hscan_each("seeks").detect {|u, d| d == (d || active_filters)}
      remove(d[0])
      CustomGame.new(uuid, d[0], filter)
      puts
    else
      REDIS.hset("seeks", uuid, data)
    end
  end
end