module Enerscore
  class ResponseParser
    attr_reader :response, :status

    def initialize(response)
      @response = response
      if @response.is_a?(Hash)
        if @response.has_key?('error')
          @status = :error
        elsif ((@response['status']['total'] == 0) if @response['status'])
          @status = :no_results
        else
          raise 'Unhandled hash request from Enerscore API'
        end
      elsif @response.is_a?(Array)
        @status = :success
      else
        if @response.respond_to?(:code) &&
            @response.code.between?(500, 600)
          @status = :server_error
        else
          raise 'Unhandled request type from Enerscore API'
        end
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
  end
end

