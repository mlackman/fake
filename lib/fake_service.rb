require 'rack'

Thread.abort_on_exception = true

module Fake
  class Response
    attr_reader :body, :status

    def initialize(body, status)
      @body = body
      @status = status
    end

  end

  #
  # Queue which returns last value forever
  #
  class InfiniteQueue
    def initialize
      @current_item_index = 0
      @items = []
    end

    def <<(item)
      @items << item
    end

    def next
      item = @items[@current_item_index]
      @current_item_index += 1 if @current_item_index < (@items.count - 1)
      item
    end
  end

  class RequestHandler
    attr_reader :responses

    def initialize(path)
      @path = path
      @responses = InfiniteQueue.new
    end

    def call(request)
      return unless request.path.eql? @path
      current_response = @responses.next
      Rack::Response.new([current_response.body], status=current_response.status)
    end

  end

  class RequestHandlerBuilder
    def initialize(request_handler)
      @request_handler = request_handler
    end

    #
    # DSL
    #
    def respond(body:nil, status:200)
      @request_handler.responses << Response.new(body, status)
      self
    end
  end

  class RackApp
    def initialize
      @handlers = []
    end

    def add_request_handler(request_handler)
      @handlers << request_handler
    end

    def call(env)
      @handlers.each do |handler|
        response = handler.call(Rack::Request.new(env))
        return response if response
      end
    end
  end

  class Server

    def start(rack_app, port)
      mutex = Mutex.new
      server_started = ConditionVariable.new
      @server_thread = Thread.new(rack_app, port) do |app, port|
        Rack::Handler::WEBrick.run(app, Port:port) do
          server_started.signal
        end
      end
      mutex.synchronize do
        server_started.wait(mutex)
      end
    end

    def stop
      Rack::Handler::WEBrick.shutdown
      @server_thread.join
    end
  end

  class Service
    def initialize(port=8080)
      @app = RackApp.new
      @port = port[:port]
      @server = Server.new
    end

    def get(path)
      request_handler = RequestHandler.new(path)
      @app.add_request_handler(request_handler)
      RequestHandlerBuilder.new(request_handler)
    end

    def start
      @server.start(@app, @port)
    end

    def stop
      @server.stop
    end
  end
end

