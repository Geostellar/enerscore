module Enerscore
  class ResponseParser
    attr_reader :response, :status

    def initialize(response)
      @response = response
      if @response == :network_timeout
        @status = :network_timeout
      elsif @response == :request_exception
        @status = :request_exception
      elsif server_error_response?(response)
        @status = :server_error
      else
        case response_object(response)
        when Hash
          if @response.has_key?('error')
            @status = :error
          elsif has_no_results?(response)
            @status = :no_results
          else
            raise 'Unhandled hash request from Enerscore API'
          end
        when Array
          @status = :success
        end
      end

      unless @status
        raise 'Unhandled request type from Enerscore API'
      end
    end

    def error?
      status == :error
    end

    def no_results?
      status == :no_results
    end

    def results
      @response if success?
    end

    def result
      if results
        @result ||= Enerscore::Result.new results.first
      end
    end

    def success?
      status == :success
    end

    private
    def has_no_results?(response)
      response['status'] &&
        response['status']['total'] == 0
    end

    def response_object(response)
      if response.respond_to?(:parsed_response)
        response.parsed_response
      else
        response
      end
    end

    def server_error_response?(response)
      response.respond_to?(:code) &&
        response.code.between?(500, 600)
    end
  end
end

