module Fake
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
end


