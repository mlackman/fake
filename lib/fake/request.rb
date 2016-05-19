module Fake
  class Request < Rack::Request

    def POST
      params = super
      if content_type && content_type.downcase == 'application/json'
        hash = JSON.parse(body_string)
        params.merge!(hash)
      end
      params
    end

    def body_string
      @body_string ||= body.gets
    end

  end
end
