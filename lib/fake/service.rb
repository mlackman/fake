module Fake
  class Service
    def initialize(port:8080, bind:"localhost")
      @app = RackApp.new
      @webrick_config = {Port:port, BindAddress:bind}
      @server = Server.new
    end

    def add_request_handler(request_handler)
      @app.add_request_handler(request_handler)
    end

    def get(path)
      request_handler = RequestHandler.new(:get, path)
      @app.add_request_handler(request_handler)
      RequestHandlerBuilder.new(request_handler)
    end

    def start
      @server.start(@app, @webrick_config)
    end

    def stop
      @server.stop
    end
  end
end


