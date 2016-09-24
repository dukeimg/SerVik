class Seek
  def initialize(uuid, data)
    filter = data.select {|key, value| value if data[key] != 0}

    # Temporal debug messages
    puts "data: #{data}"
    puts "filter: #{filter}"

    if d = REDIS.hscan_each("seeks").detect {|u, d| d == (d || filter)}
      remove(d[0])
      Game.new(uuid, d[0], filter)
      puts
    else
      REDIS.hset("seeks", uuid, data)
    end
  end

  def self.remove(uuid)
    REDIS.hdel("seeks", uuid)
  end

  def self.clear_all
    REDIS.del("seeks")
  end
end