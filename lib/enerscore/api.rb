require 'httparty'

module Enerscore
  class Api
    include HTTParty

    base_uri "http://api-alpha.enerscore.com/api"
    NEIGHBORS_URI = "/address/neighbors/"

    attr_accessor :cache

    def initialize(cache_store=nil)
      if cache_store
        @cache = Enerscore::Cache.new(cache_store, NEIGHBORS_URI)
      end
    end

    def fetch(address)
      get_request = get_request(address)
      request_response = Enerscore::ResponseParser.new get_request
      request_response.result
    end

    def pre_cache(address, object)
      if cache
        cache.write address, object
      else
        raise 'No cache present'
      end
    end

    private
    def get_request(address)
      url = fetch_uri(address)

      if cache
        if cached = cache.read(address)
          cached
        else
          get_request = self.class.get url
          if get_request.code == 200
            cache.write address, get_request
          end
          get_request
        end
      else
        self.class.get url
      end
    end

    def fetch_uri(address)
      NEIGHBORS_URI +
        URI.encode_www_form_component(address) +
        ".json"
    end
  end
end
