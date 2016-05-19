module Fake
  class << self
    def start(port:8080, bind:"localhost")
      @fake_service = Service.new(port:port, bind:bind)
      @fake_service.start
    end

    def stop
      # todo: something better, stop fails if start and stop comes almost the same
      # needs some check that if thread is alive and if not then yield (or something...)
      sleep 0.5
      @fake_service.stop
    end

    def clear
      @fake_service.clear
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
