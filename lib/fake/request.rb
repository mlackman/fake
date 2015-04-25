module Fake
  class Request < Rack::Request

    def POST
      params = super
      if content_type && content_type.downcase == 'application/json'
        hash = JSON.parse(body.gets)
        params.merge!(hash)
      end
      params
    end

  end
end
