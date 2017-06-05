require 'spec_helper'
require 'httparty'
require 'pry'

describe 'Fake Service' do
  let(:fs) { Fake::Service.new(port:4567) }
  after(:each) { fs.stop }

  describe "configuration" do
    it "can be bind to different addresses" do
      Fake.start(bind:'127.0.0.1', port:8080)
      Fake.get('/').respond(body:"ok")
      expect(HTTParty.get('http://127.0.0.1:8080').body).to eq "ok"
      Fake.stop
    end
  end

  describe "many fake services on different ports" do
    xit "handles requests ok" do
    end
  end

  describe "Simple service without parameters" do
    before(:each) { Fake.start(port:4568) }
    after(:each) { Fake.stop }

    it "can handle get" do
      Fake.get('/').respond(body:"_response_")
      response = HTTParty.get('http://localhost:4568')
      expect(response.body).to eq "_response_"
    end

    it "can handle shitty path" do
      Fake.get('/path/?id=5').respond(body: 'ok')
      expect(HTTParty.get('http://localhost:4568/path/?id=5').body).to eq 'ok'
    end

    it "can handle post" do
      Fake.post('/').respond(body:"_response_")
      response = HTTParty.post('http://localhost:4568')
      expect(response.body).to eq "_response_"
    end
    it "is possible to clear request handlers" do
      Fake.get('/').respond(body:"response")
      Fake.clear
      Fake.get('/').respond(body:"other response")
      response = HTTParty.get('http://localhost:4568')
      expect(response.body).to eq "other response"
    end

  end

  describe "Response code" do
    it "returns assigned response code" do
      Fake.start(port:4567)
      Fake.get('/').respond(status:404)
      response = HTTParty.get('http://localhost:4567')
      expect(response.code).to eq 404
      Fake.stop
    end
  end

  describe "Headers" do
    it "sets headers to response" do
      Fake.start(port:4567)
      Fake.get('/').respond(headers: {"x-header" => "someurl"})
      response = HTTParty.get('http://localhost:4567')
      expect(response.headers).to include("x-header")
      expect(response.headers['x-header']).to eq "someurl"
      Fake.stop
    end
  end

  describe "Paths" do
    describe "static paths" do
      it "routes requests to correct handler" do
        Fake.start(port:4567)
        Fake.get('/cart').respond(body:"1")
        Fake.get('/order/new').respond(body:"2")

        expect(HTTParty.get('http://localhost:4567/cart'     ).response.body).to eq "1"
        expect(HTTParty.get('http://localhost:4567/order/new').response.body).to eq "2"
        Fake.stop
      end
    end

    describe "dynamic paths" do
      it "routes request to match path variables" do
        Fake.start(port:4567)
        Fake.get('/cart/:id/status').respond(body:"ok")
        expect(HTTParty.get('http://localhost:4567/cart/path/status').response.body).to eq "ok"
        Fake.stop
      end
    end

    describe "Responding specific request" do
      before do
        Fake.start(port:4567)
      end
      after do
        Fake.stop
      end

      it "can respond based on query parameter" do
        # what about specific parameters vs some parameter
        Fake.get('/cart/option?id=5').respond(body: "ok")
        expect(HTTParty.get('http://localhost:4567/cart/option?id=5').response.body).to eq "ok"
      end

      it "can resbond based on specific body" do
        Fake.post('/cart').body('{"var":1,"var2":"3"}').respond(body:"1")
        Fake.post('/cart').body('{"var":1,"var2":"4"}').respond(body:"2")
        expect(HTTParty.post('http://localhost:4567/cart', body:'{"var":1,"var2":"4"}').response.body).to eq "2"
        expect(HTTParty.post('http://localhost:4567/cart', body:'{"var":1,"var2":"3"}').response.body).to eq "1"
     end
    end

    describe "Checking request parameters" do
      it "can verify single parameter" do
        Fake.start(port:4567)
        Fake.get('/cart').respond(body:'')
        HTTParty.get('http://localhost:4567/cart?id=5&status=pending')
        params = Fake::Requests.request(:get, '/cart').params
        expect(params.has_key? 'id')
        expect(params.has_key? 'status')
        expect(params["id"]).to eq "5"
        expect(params["status"]).to eq "pending"
        Fake.stop

      end

      xit "can name a request to ease matching of request" do
        Fake.start
        Fake.get('/cart', name: :my_cart_request)
        HTTParty.get('http://localhost:4567/cart?id=5&status=pending')
        expect(Fake::Requests.request(:my_cart_request)).not_to be nil
        Fake.stop
      end

      context "from post request" do
        before do
          Fake.start(port:4567)
          Fake.post('/').respond(status:400)
        end
        after do
          Fake.stop
        end
        context "when content-type is 'application/json'" do
          before do
            HTTParty.post('http://localhost:4567/', body:{"data" => {"some"=>"1", "thing"=>"0"}}.to_json,
                                                    headers: {"Content-Type"=>"application/json"})
          end
          it "sets the parsed json to params" do
            request = Fake::Requests.request(:post, '/')
            expect(request.params['data']['some']).to eq '1'
            expect(request.params['data']['thing']).to eq '0'
          end

          it "the json is available for subsequent requests" do
            request = Fake::Requests.request(:post, '/')
            expect(request.params['data']['some']).to eq '1'
            expect(request.params['data']['thing']).to eq '0'
            request = Fake::Requests.request(:post, '/')
            expect(request.params['data']['some']).to eq '1'
            expect(request.params['data']['thing']).to eq '0'
          end

          context "when post body not received" do
            xit "raises error or what?" do
            end
          end
        end

      end

    end

    describe "ordering" do
      xit "routes request to latest handler, which match the request" do
      end
    end
  end

  describe "Setting responses" do
    describe "chaining responses" do
      it "returns responses in order" do
        Fake.start(port:4567)
        Fake.get('/cart').respond(body:"1").respond(body:"2").respond(body:"3")
        expect(HTTParty.get('http://localhost:4567/cart').response.body).to eq "1"
        expect(HTTParty.get('http://localhost:4567/cart').response.body).to eq "2"
        expect(HTTParty.get('http://localhost:4567/cart').response.body).to eq "3"
        expect(HTTParty.get('http://localhost:4567/cart').response.body).to eq "3"
        expect(HTTParty.get('http://localhost:4567/cart').response.body).to eq "3"
        Fake.stop
      end
    end
  end

  describe "using block" do
    it "uses block return value as response" do
      Fake.start(port:4567)
      Fake.get('/').respond do
        "my response"
      end
      expect(HTTParty.get('http://localhost:4567').response.body).to eq "my response"
      Fake.stop
    end

    it "can access response object" do
      Fake.start(port:4567)
      Fake.get('/').respond do |r|
        r.status = 201
        "response"
      end
      expect(HTTParty.get('http://localhost:4567').response.code).to eq "201"
    end


  end

end
