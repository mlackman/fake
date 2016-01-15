require 'spec_helper'


describe Fake::Response do

  it "raises exception if body and block are given" do
    expect { Fake::Response.new("ok", 200) {} }.to raise_error
  end

  it "evaluates the block when body is queried" do
    r = Fake::Response.new(nil, 200) { "response" }
    expect(r.body).to eq "response"
  end

end
