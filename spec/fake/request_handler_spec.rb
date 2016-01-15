require 'spec_helper'

describe Fake::RequestHandler do

  context "when path equals request handlers path" do
    context "when operation matches request operation" do
      it "returns response" do
        rh = Fake::RequestHandler.new(:get, '/home')
        rh.responses << Fake::Response.new("", "200 OK", {})
        expect(rh.call(get_request('http://localhost/home'))).not_to eq nil
      end
    end

    context "when operation does not match with request handler operation" do
      it "returns nil" do
        rh = Fake::RequestHandler.new(:get, '/home')
        expect(rh.call(post_request('http://localhost/home'))).to eq nil
      end
    end
  end

  context "when path does not match with request handlers path" do
    it "returns nil" do
      rh = Fake::RequestHandler.new(:get, '/something')
      expect(rh.call(get_request('http://localhost/home'))).to eq nil
    end
  end
end
