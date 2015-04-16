module Fake
  class << self
    def start(port:8080, bind:"localhost")
      @fake_service = Service.new(port:port, bind:bind)
      @fake_service.start
    end

    def stop
      @fake_service.stop
    end
  end

  def self.method_missing(method, *args, &block)
    if [:post, :get].include?(method)
      request_handler = RequestHandler.new(method, *args)
      @fake_service.add_request_handler(request_handler)
      RequestHandlerBuilder.new(request_handler)
    else
      super
    end
  end

end
