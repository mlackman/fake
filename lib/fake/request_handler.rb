module Fake
  class RequestHandler
    attr_reader :responses
    attr_accessor :body

    #
    # Creates handler for http request
    # method: :get, :post, :put etc
    # path: Path of the request like '/home/something'
    def initialize(method, path)
      @method = method
      @path = Path.new(path)
      @responses = InfiniteQueue.new
      @body = nil
    end

    def call(request)
      if should_serve?(request)
        current_response = @responses.next
        raise "FAKE service: No response set for request #{presentation}" if current_response.nil?
        current_response.evaluate()
        Rack::Response.new([current_response.body], status=current_response.status, header=current_response.headers)
      end
    end

  private
    def should_serve?(request)
      should_serve = @path.eql?(request.path) && request.request_method.eql?(@method.to_s.upcase)
      if should_serve && @body != nil
        should_serve = @body == request.body_string
      end
      should_serve
    end

    def presentation
      @path
    end
  end
end


