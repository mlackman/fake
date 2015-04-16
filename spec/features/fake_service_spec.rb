require 'spec_helper'
require 'httparty'

describe 'Fake Service' do
  let(:fs) { Fake::Service.new(port:4567) }
  after(:each) { fs.stop }

  describe "configuration" do
    let(:fs) { Fake::Service.new(bind:'127.0.0.1') }
    it "can be bind to different addresses" do
      fs.get('/').respond(body:"ok")
      fs.start
      expect(HTTParty.get('http://127.0.0.1:8080').body).to eq "ok"
    end
  end

  describe "many fake services on different ports" do
    xit "handles requests ok" do
    end
  end

  describe "Simple service without parameters" do
    before(:each) { Fake.start(port:4567) }
    after(:each) { Fake.stop }

    it "can handle get" do
      Fake.get('/').respond(body:"_response_")
      response = HTTParty.get('http://localhost:4567')
      expect(response.body).to eq "_response_"
    end

    it "can handle post" do
      Fake.post('/').respond(body:"_response_")
      response = HTTParty.post('http://localhost:4567')
      expect(response.body).to eq "_response_"
    end
  end

  describe "Response code" do
    it "returns assigned response code" do
      fs.get('/').respond(status:404)
      fs.start

      response = HTTParty.get('http://localhost:4567')
      expect(response.code).to eq 404
    end
  end

  describe "Paths" do
    describe "static paths" do
      it "routes requests to correct handler" do
        fs.get('/cart').respond(body:"1")
        fs.get('/order/new').respond(body:"2")
        fs.start

        expect(HTTParty.get('http://localhost:4567/cart'     ).response.body).to eq "1"
        expect(HTTParty.get('http://localhost:4567/order/new').response.body).to eq "2"
      end
    end

    describe "dynamic paths" do
      xit "routes request to match path variables" do
        fs.get('/cart/:id/status').response(body:"ok")
        fs.start
        expect(HTTParty.get('http://localhost:4567/cart/path/status').response.body).to eq "ok"
      end
    end

    describe "Responding specific request" do
      xit "can respond based on query parameter" do
        # what about specific parameters vs some parameter
        fs.get('/cart/option').param('id=5').respond("ok") # Matches /cart/option?id=5,
      end
    end

    describe "Checking request parameters" do
      it "can verify single parameter" do
        fs.get('/cart')
        fs.start
        HTTParty.get('http://localhost:4567/cart?id=5&status=pending')
        params = Fake::Requests.request(:get, '/cart').params
        expect(params.has_key? 'id')
        expect(params.has_key? 'status')
        expect(params["id"]).to eq "5"
        expect(params["status"]).to eq "pending"
      end

      xit "can name a request to ease matching of request" do
        fs.get('/cart', name: :my_cart_request)
        fs.start
        HTTParty.get('http://localhost:4567/cart?id=5&status=pending')
        expect(Fake::Requests.request(:my_cart_request)).not_to be nil
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
        fs.get('/cart').respond(body:"1").respond(body:"2").respond(body:"3")
        fs.start
        expect(HTTParty.get('http://localhost:4567/cart').response.body).to eq "1"
        expect(HTTParty.get('http://localhost:4567/cart').response.body).to eq "2"
        expect(HTTParty.get('http://localhost:4567/cart').response.body).to eq "3"
        expect(HTTParty.get('http://localhost:4567/cart').response.body).to eq "3"
        expect(HTTParty.get('http://localhost:4567/cart').response.body).to eq "3"
      end
    end
  end

end
