require 'httparty'

module Enerscore
  class Api
    include HTTParty

    base_uri "http://ec2-54-209-120-96.compute-1.amazonaws.com:8080"
    default_timeout 2

    FULL_ADDRESS_URI = "/addresses/search/fulladdress.json"

    attr_accessor :cache

    def initialize(cache_store=nil)
      if cache_store
        @cache = Enerscore::Cache.new(cache_store, FULL_ADDRESS_URI)
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
    rescue Net::OpenTimeout => e
      :network_timeout
    rescue Net::ReadTimeout => e
      :network_timeout
    rescue SocketError => e
      :network_timeout
    rescue Exception => e
      :request_exception
    end

    def fetch_uri(address)
      FULL_ADDRESS_URI +
        '?' +
        'address=' +
        URI.encode_www_form_component(address)
    end
  end
end
