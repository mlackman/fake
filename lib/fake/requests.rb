module Fake
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
