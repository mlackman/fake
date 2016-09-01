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

    def start
      @server.start(@app, @webrick_config)
    end

    def stop
      @server.stop
    end

    def clear
      @app.clear_request_handlers
    end
  end
end


