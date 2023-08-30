# frozen_string_literal: true

RSpec.describe Tsumanne do
  it "has a version number" do
    expect(Tsumanne::VERSION).not_to be nil
  end

  context "API" do
    let(:api) { Tsumanne::API }

    it "ok when initializing with valid symbol" do
      expect(api.new(board_id: :img).board_id).to eql("si")
    end

    it "raises TypeError when initializing with invalid symbol" do
      expect{ api.new(board_id: :si) }.to raise_error(TypeError)
    end

    it "raises ArgumentError when initializing without board_id" do
      expect{ api.new("si") }.to raise_error(ArgumentError)
    end
  end
end
