module Enerscore
  class Cache

    def initialize(cache_store, prefix=nil)
      if cache_store
        @cache_store = cache_store
        @prefix = prefix
      else
        raise 'Cache store cannot be nil'
      end
    end

    def clear_cache
      keys = @cache_store.keys "#{namespace}*"
      @cache_store.del(*keys) unless keys.empty?
    end

    def read(key)
      ck = cache_key(key)

      if value = @cache_store.get(ck)
        value
      end
    end

    def write(key, value)
      ck = cache_key(key)
      @cache_store.set ck, value
    end

    def delete(key)
      ck = cache_key(key)
      @cache_store.del(ck) == 1
    end

    protected
    def cache_key(key)
      "#{namespace}#{@prefix}#{key}"
    end

    def namespace
      "enerscore::"
    end
  end
end
