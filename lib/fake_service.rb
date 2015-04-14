require 'rack'
require 'singleton'
require 'WEBrick'

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
      request = Rack::Request.new(env)
      # TODO: Make this part of rack stack
      Requests.add_request(request)

      @handlers.each do |handler|
        response = handler.call(request)
        return response if response
      end
      raise "NO HANDLER for #{request.path}"
    end
  end

  class Server

    def start(rack_app, webrick_config)
      return unless @server_thread.nil?
      mutex = Mutex.new
      server_started = ConditionVariable.new
      @server_thread = Thread.new(rack_app, webrick_config) do |app, config|
        @server = WEBrick::HTTPServer.new(config)
        @server.mount "/", Rack::Handler::WEBrick, app
        server_started.signal
        @server.start
      end
      mutex.synchronize do
        server_started.wait(mutex)
      end
    end

    def stop
      unless @server_thread.nil?
        @server.shutdown
        @server_thread.join if @server_thread.alive?
        @server_thread = nil
      end
    end
  end

  class Service
    def initialize(port:8080, bind:"localhost")
      @app = RackApp.new
      @webrick_config = {Port:port, BindAddress:bind}
      @server = Server.new
    end

    def get(path)
      request_handler = RequestHandler.new(path)
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

  class Requests

    attr_accessor :requests
    include Singleton
    class << self
      def request(method, path)
        matching_request = nil
        instance.requests.each do |request|
          if request.request_method == method.to_s.upcase &&
             request.path == path
            matching_request = request
          end
        end
        matching_request
      end

      def add_request(request)
        instance.requests << request
      end
    end
  private
    def initialize
      @requests = []
    end


  end
end

