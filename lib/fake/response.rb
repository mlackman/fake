
module Fake
  class Response
    attr_reader :body, :status

    def initialize(body, status, &block)
      raise "Response created with body and block. Only other can be given" if body && block
      @body = body
      @status = status
      @block = block
    end

    def body
      if !@body && @block
        @body = @block.call
      end
      @body
    end

  end
end
