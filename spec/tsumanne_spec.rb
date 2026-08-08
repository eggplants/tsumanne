# typed: false
# frozen_string_literal: true

require "uri"

RSpec.describe Tsumanne do
  it "has a version number" do
    expect(Tsumanne::VERSION).not_to be_nil
  end

  describe Tsumanne::API do
    let(:api) { described_class }

    describe "#initializing" do
      it "works well, with valid symbol" do
        expect(api.new(board_id: :img).board_id).to eql("si")
      end

      it "raises TypeError, with invalid symbol" do
        expect { api.new(board_id: :si) }.to raise_error(TypeError)
      end

      it "raises ArgumentError, without board_id" do
        expect { api.new("si") }.to raise_error(ArgumentError)
      end
    end

    describe "#get_threads" do
      let(:instance) { described_class.new(board_id: :img) }

      it "returns a successful response" do
        expect(instance.get_threads.success).to be(true)
      end
    end

    describe "#get_thread_mht" do
      let(:instance) { described_class.new(board_id: :img) }

      it "returns the archived thread document" do
        expect(instance.get_thread_mht(129_691.to_s)).to include("charset=Shift_JIS")
      end

      it "raises Tsumanne::Error, for an unarchived thread" do
        expect { instance.get_thread_mht(999_999_999.to_s) }.to raise_error(Tsumanne::Error)
      end
    end

    describe "#get_thread_from_path" do
      let(:instance) { described_class.new(board_id: :img) }

      it "returns the archived thread document" do
        expect(instance.get_thread_from_path("2010/05/05/129691")).to include("charset=Shift_JIS")
      end

      it "returns nil, with an unparsable path" do
        expect(instance.get_thread_from_path("not/a/thread/path")).to be_nil
      end
    end

    describe "#search_thread_from_uri" do
      let(:instance) { described_class.new(board_id: :img) }

      it "returns the archived thread matching the source URI" do
        target_uri = URI.parse("https://img.2chan.net/b/res/86279902.htm")
        expect(instance.search_thread_from_uri(target_uri).logs.map(&:path)).to eql(["data/2010/05/05/129691"])
      end

      it "returns no logs, for an unarchived URI" do
        target_uri = URI.parse("https://img.2chan.net/b/res/1.htm")
        expect(instance.search_thread_from_uri(target_uri).logs).to be_empty
      end
    end

    describe "#search_indexes" do
      let(:instance) { described_class.new(board_id: :img) }

      it "returns a successful response" do
        expect(instance.search_indexes(keyword: "深淵").success).to be(true)
      end

      it "lists every index, without a keyword" do
        expect(instance.search_indexes.tags).not_to be_empty
      end
    end

    describe "#register_thread" do
      let(:instance) { described_class.new(board_id: :img) }

      it "returns a successful response" do
        target_uri = URI.parse("https://img.2chan.net/b/res/0.htm")
        expect(instance.register_thread(target_uri).success).to be(true)
      end
    end
  end
end
