# FAKE

## simple example
```ruby
  describe "Simple service without parameters" do
    before(:each) { Fake.start(port:4568) }
    after(:each) { Fake.stop }

    it "can handle get" do
      Fake.get('/').respond(body:"_response_")
      response = HTTParty.get('http://localhost:4568')
      expect(response.body).to eq "_response_"
    end
  end
```


