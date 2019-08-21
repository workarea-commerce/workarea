# from Geocoder GitHub Repository
#
# This class implements a cache with simple delegation to the Redis store, but
# when it creates a key/value pair, it also sends an EXPIRE command with a TTL.
#
module Workarea
  class AutoexpireCacheRedis
    def initialize(store, ttl = 259200) # "time to live" of 3 days
      @store = store
      @ttl = ttl
    end

    def [](url)
      @store.get(url)
    end

    def []=(url, value)
      @store.setex(url, @ttl, value)
    end

    def keys
      @store.keys
    end

    def del(url)
      @store.del(url)
    end
  end
end
