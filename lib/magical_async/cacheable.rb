module MagicalAsync

  class CacheableProcess
    attr_accessor :redis_key, :redis_expire, :callback

    def initialize(key, expire, callback)
      @redis_key = key
      @redis_expire = expire
      @callback = callback
    end
  end

  def self.cacheable(key, expire, callback)
    CacheableProcess.new key, expire, callback
  end

end
