require 'spec_helper'
require 'httparty'

describe 'Fake Service' do
  let(:fs) { Fake::Service.new(port:4567) }
  after(:each) { fs.stop }

  describe "Simple service without parameters" do
    it "simple to setup" do
      fs.get('/').respond(body:"_response_")
      fs.start

      response = HTTParty.get('http://localhost:4567')
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
