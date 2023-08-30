# frozen_string_literal: true

require "uri"

RSpec.describe Tsumanne do
  it "has a version number" do
    expect(Tsumanne::VERSION).not_to be nil
  end

  context "API" do
    let(:api) { Tsumanne::API }

    describe "#initializing" do
      it "works well, with valid symbol" do
        expect(api.new(board_id: :img).board_id).to eql("si")
      end

      it "raises TypeError, with invalid symbol" do
        expect{ api.new(board_id: :si) }.to raise_error(TypeError)
      end

      it "raises ArgumentError, without board_id" do
        expect{ api.new("si") }.to raise_error(ArgumentError)
      end

      it "raises ArgumentError, without board_id" do
        expect{ api.new("si") }.to raise_error(ArgumentError)
      end
    end

    describe "#get_threads" do
      let(:instance) { Tsumanne::API.new(board_id: :img) }
      it "works" do
        expect(instance.get_threads["success"]).to eql(true)
      end
    end

    describe "#get_thread_mht" do
      let(:instance) { Tsumanne::API.new(board_id: :img) }
      it "works" do
        target_content_header =  %{Content-Type: text/html; charset="Shift_JIS"}
        expect(instance.get_thread_mht(129691.to_s).body).to include(target_content_header)
      end
    end

    describe "#get_thread_from_path" do
      let(:instance) { Tsumanne::API.new(board_id: :img) }
      it "works" do
        target_content_header =  %{Content-Type: text/html; charset="Shift_JIS"}
        expect(instance.get_thread_from_path("2010/05/05/129691").body).to include(target_content_header)
      end
    end

    describe "#search_thread_from_uri" do
      let(:instance) { Tsumanne::API.new(board_id: :img) }
      it "works" do
        target_uri = URI.parse("https://img.2chan.net/b/res/86279902.htm")
        expect(instance.search_thread_from_uri(target_uri)["success"]).to eql(true)
      end
    end

    describe "#search_indexes" do
      let(:instance) { Tsumanne::API.new(board_id: :img) }
      it "works" do
        expect(instance.search_indexes(keyword: "深淵")["success"]).to eql(true)
      end
    end

    describe "#register_thread" do
      let(:instance) { Tsumanne::API.new(board_id: :img) }
      it "works" do
        target_uri = URI.parse("https://img.2chan.net/b/res/0.htm")
        expect(instance.register_thread(target_uri)["success"]).to eql(true)
      end
    end
  end
end
