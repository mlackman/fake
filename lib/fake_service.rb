require 'rack'
require 'singleton'
require 'WEBrick'
require_relative './fake/server.rb'
require_relative './fake/service.rb'
require_relative './fake/request_handler.rb'
require_relative './fake/requests.rb'
require_relative './fake/request.rb'
require_relative './fake/fake.rb'
require_relative './fake/response.rb'
require_relative './fake/path.rb'

Thread.abort_on_exception = true

module Fake
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

  class RequestHandlerBuilder

    def initialize(request_handler)
      @request_handler = request_handler
    end

    #
    # DSL
    #

    # request body, which must match
    def body(body)
      @request_handler.body = body
      self
    end

    def respond(body:nil, status:200, headers:{}, &block)
      @request_handler.responses << Response.new(body, status, headers,  &block)
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

    def clear_request_handlers
      @handlers = []
    end

    def call(env)
      request = Fake::Request.new(env)

      # TODO: Make this part of rack stack
      Requests.add_request(request)

      @handlers.each do |handler|
        response = handler.call(request)
        return response if response
      end
      raise "NO HANDLER for #{request.path}"
    end
  end

end

