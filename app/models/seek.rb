class Seek
  def self.create(uuid, data)
    filter = data.select {|key, value| value if data[key] != 0}
    if d = REDIS.hscan_each("seeks").detect {|u, d| d == (d || filter)}
      remove(d[0])
      Game.init(uuid, d[0])
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