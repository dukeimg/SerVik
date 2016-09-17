class Seek
  def self.create(uuid, data)
    filter = data.select {|key, value| value if data[key] != 0}
    REDIS.hscan_each("seeks").each do |u, d|
      puts d, filter
      if d == filter
        puts 'Found you!'
        Game.init(uuid, u)
        return
      end
    end
    REDIS.hset("seeks", uuid, data)
  end

  def self.remove(uuid)
    REDIS.hdel("seeks", uuid)
  end

  def self.clear_all
    REDIS.del("seeks")
  end
end