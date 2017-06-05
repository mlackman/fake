require 'spec_helper'

describe Fake::RequestHandler do

  context "when path equals request handlers path" do
    context "when operation matches request operation" do
      it "returns response" do
        rh = Fake::RequestHandler.new(:get, '/home')
        rh.responses << Fake::Response.new("", "200 OK", {})
        expect(rh.call(get_request('http://localhost/home'))).not_to eq nil
      end

      context "when dynamic path used" do
        it "returns response" do
          rh = Fake::RequestHandler.new(:get, '/home/:id/new')
          rh.responses << Fake::Response.new("", "200 OK", {})
          expect(rh.call(get_request('http://localhost/home/5/new'))).not_to eq nil
        end
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

  context "when path contains query parameters" do
    context "when path and parameters match" do
      it "returns the response" do
        rh = Fake::RequestHandler.new(:get, '/home?param=1')
        rh.responses << Fake::Response.new("", "200 OK", {})
        expect(rh.call(get_request('http://localhost/home?param=1'))).not_to eq nil
      end
    end

    context "when path matches but parameter does not match" do
      it "returns nil" do
        rh = Fake::RequestHandler.new(:get, '/home?param=1')
        rh.responses << Fake::Response.new("", "200 OK", {})
        expect(rh.call(get_request('http://localhost/home?param=2'))).to eq nil
      end
    end
  end

  context "when path is not well formatted with query params" do
    context "when path and query matches" do
      it "returns the response" do
        rh = Fake::RequestHandler.new(:get, '/home/?param=1')
        rh.responses << Fake::Response.new("", "200 OK", {})
        expect(rh.call(get_request('http://localhost/home/?param=1'))).not_to eq nil
      end
    end
    context "when path matches but query does not" do
      it "returns the response" do
        rh = Fake::RequestHandler.new(:get, '/home/?param=2')
        rh.responses << Fake::Response.new("", "200 OK", {})
        expect(rh.call(get_request('http://localhost/home/?param=1'))).to eq nil
      end
    end

  end
end
