module Fake
  class RequestHandler
    attr_reader :responses

    #
    # Creates handler for http request
    # method: :get, :post, :put etc
    # path: Path of the request like '/home/something'
    def initialize(method, path)
      @method = method
      @path = path
      @responses = InfiniteQueue.new
    end

    def call(request)
      if request.path.eql?(@path) && request.request_method.eql?(@method.to_s.upcase)
        current_response = @responses.next
        raise "FAKE service: No response set for request #{presentation}" if current_response.nil?
        current_response.evaluate()
        Rack::Response.new([current_response.body], status=current_response.status, header=current_response.headers)
      end
    end

  private
    def presentation
      @path
    end
  end
end


