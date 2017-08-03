module Enerscore
  class ResponseParser
    attr_reader :response, :status

    def initialize(response)
      @response = response

      case @response
      when :network_timeout
        @status = :network_timeout
      when :request_exception
        @status = :request_exception
      else
        if server_error_response?(response)
          @status = :server_error
        else
          @parsed_response = response_object(response)
          @status = :success
        end
      end
    end

    def result
      if results
        @result ||= Enerscore::Result.new results.first
      end
    end

    private
    def has_results?(response)
      response.dig('page', 'totalElements').to_i > 0
    end

    def response_object(response)
      JSON.parse response
    end

    def results
      if @parsed_response
        @parsed_response.dig('_embedded', 'addresses')
      end
    end

    def server_error_response?(response)
      response.respond_to?(:code) &&
        response.code.between?(500, 600)
    end
  end
end

