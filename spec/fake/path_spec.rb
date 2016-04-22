require 'spec_helper'


RSpec.describe Fake::Path do

  describe "#eql?" do
    context "when path is static" do
      context "and paths are equals" do

        it "returns true" do
          expect(Fake::Path.new("/path").eql?("/path")).to eq true
        end
      end

      context "and paths are not equal" do
        it "returns false" do
          expect(Fake::Path.new("/something").eql?("/path")).to eq false
        end
      end
    end

    context "when path is dynamic" do
      context "and paths are equals" do
        it "returns true" do
          expect(Fake::Path.new("/:id/path/:id2/value").eql?("/value/path/some/value")).to eq true
        end
      end

      context "and different amount of path parts" do
        it "returns false" do
          expect(Fake::Path.new("/:id/path").eql?("/value/something/path")).to eq false
        end

        it "returns false" do
          expect(Fake::Path.new("/:id/path/:id2/some").eql?("/value")).to eq false
        end
      end

      context "and paths are not equals" do
        it "returns false" do
          expect(Fake::Path.new("/:id/someghing/:id2/path").eql?("/value/something/path")).to eq false
        end
      end
    end
  end

end
