require 'httparty'

module Enerscore
  class Api
    include HTTParty

    base_uri "http://api-alpha.enerscore.com/api"
    NEIGHBORS_URI = "/address/neighbors/"

    def fetch(address)
      url = fetch_uri(address)
      get_request =  self.class.get url
      request_response = Enerscore::ResponseParser.new get_request
      request_response.result
    end

    private
    def fetch_uri(address)
      NEIGHBORS_URI +
        URI.encode_www_form_component(address) +
        ".json"
    end
  end
end
