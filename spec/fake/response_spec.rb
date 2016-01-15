require 'spec_helper'


describe Fake::Response do

  it "raises exception if body and block are given" do
    expect { Fake::Response.new("ok", 200, {}) {} }.to raise_error
  end

  describe "#evaluate" do
    it "makes the body for the response from the block" do
      r = Fake::Response.new(nil, 200, {}) { "response" }
      r.evaluate()
      expect(r.body).to eq "response"
    end

    it "makes the body from the body param" do
      r = Fake::Response.new("response", 200, {})
      r.evaluate()
      expect(r.body).to eq "response"
    end

    it "makes the response object available for the block" do
      r = Fake::Response.new(nil, 200, {}) {|r| r.status = 201 }
      r.evaluate()
      expect(r.status).to eq 201

    end
  end

end
