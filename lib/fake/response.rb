
module Fake
  class Response
    attr_reader   :body
    attr_accessor :status
    attr_accessor :headers

    def initialize(body, status, headers, &block)
      raise "Response created with body and block. Only other can be given" if body && block
      @body = body
      @status = status
      @block = block
      @headers = headers
    end

    def evaluate
      if !@body && @block
        @body = @block.call(self)
      end
      @body
    end

  end
end
