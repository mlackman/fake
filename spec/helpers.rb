def get_request(url)
  request(url, method:"GET")
end

def post_request(url)
  request(url, method:"POST")
end

def request(url, options)
  Rack::Request.new(Rack::MockRequest.env_for(url, options))
end
