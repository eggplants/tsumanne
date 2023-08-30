# typed: strict

# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require "zlib"

require "mhtml"
require "sorbet-runtime"

require_relative "tsumanne/version"

# API module for tsumanne.net includes knowledge as const.
module Tsumanne
  extend T::Sig

  # API endpoint of tsumanne.net.
  BASE_URL = "https://tsumanne.net/"

  # Valid Board Identifiers.
  BOARD_IDS = T.let({ img: "si", may: "my", jun: "tj", dat: "sa", special: "sp" }.freeze, T::Hash[Symbol, String])
  # Corresponing orders to list indexes. (`index` is same as `category`.)
  INDEXES_ORDERS = T.let({ hira: "↓あ", newer: "↓新" }.freeze, T::Hash[Symbol, String])

  class Error < StandardError; end

  # API to get information fron tsumanne.net
  class API
    extend T::Sig

    sig{ returns(String) }
    attr_reader :board_id

    sig { params(board_id: Symbol).void }
    def initialize(board_id:)
      @board_id = T.let(T.must(BOARD_IDS[board_id]), String)
    end

    sig { params(page: Integer, index: String).returns(T::Hash[String, T.untyped]) }
    def get_threads(page: 1, index: "all")
      # https://tsumanne.net/si/all/1
      # https://tsumanne.net/si/hoge/1
      fetch_json(paths: [index, page.to_s])
    end

    sig { params(thread_id: String).returns(Mhtml::RootDocument) }
    def get_thread_mht(thread_id:)
      # https://tsumanne.net/si/mht.php?id=8883427
      res = fetch_json(paths: ["mht.php"], query: { id: thread_id }, method: :get_response)
      mht_gz = fetch(paths: [T.let(res["location"], String)])
      zstream = Zlib::Inflate.new
      buf = zstream.inflate(mht_gz)
      zstream.finish
      zstream.close
      Mhtml::RootDocument.new(buf)
    end

    sig { params(path: String).returns(T.nilable(Mhtml::RootDocument)) }
    def get_thread_from_path(path:)
      # https://tsumanne.net/si/data/2023/08/30/8883354/
      match_data = %r{^\d{4}/\d{2}/\d{2}/(?<thread_id>\d+)$}.match(path)
      return if match_data.nil?

      get_thread_mht(thread_id: T.must(match_data[:thread_id]))
    end

    sig { params(url: URI).returns(T::Hash[String, T.untyped]) }
    def search_thread_from_url(url:)
      # https://tsumanne.net/si/indexes.php?format=json&w=&sbmt=URL
      fetch_json(paths: ["indexes.php"], query: { w: url, sbmt: :URL })
    end

    sig { params(keyword: T.nilable(String), order: Symbol, page: Integer).returns(T::Hash[String, T.untyped]) }
    def search_indexes(keyword: nil, order: :newer, page: 1)
      # https://tsumanne.net/si/indexes.php?format=json&w=&sbmt=URL
      # https://tsumanne.net/si/indexes.php?format=json&w=&sbmt=%E2%86%93%E6%96%B0
      fetch_json(paths: ["indexes.php"], query: { w: keyword, sbmt: INDEXES_ORDERS[order], p: page })
    end

    sig { params(url: URI, indexes: T.nilable(T::Array[String])).returns(T::Hash[String, T.untyped]) }
    def register_thread(url, indexes: nil)
      # post, https://tsumanne.net/si/input.php?format=json&url=...&category=...
      fetch_json(paths: ["input"], query: { url:, category: (indexes || []).join(",") }, method: :post)
    end

    private

    sig do
      params(paths: T.nilable(T::Array[String]),
             query: T.nilable(T::Hash[Symbol, T.any(Integer, String, Symbol)]),
             method: Symbol).returns(T.nilable(String))
    end
    def fetch(paths: nil, query: nil, method: :get)
      uri = join_paths(BASE_URL, [@board_id] + (paths || []))

      case method
      when :get
        uri.query = URI.encode_www_form(query || {})
        Net::HTTP.get(uri)
      when :get_response
        uri.query = URI.encode_www_form(query || {})
        Net::HTTP.get_response(uri)
      when :post
        Net::HTTP.post(uri, query)
      end
    end

    sig do
      params(paths: T.nilable(T::Array[String]),
             query: T.nilable(T::Hash[Symbol, T.any(Integer, String, Symbol)]),
             method: Symbol).returns(T::Hash[String, T.untyped])
    end
    def fetch_json(paths: nil, query: nil, method: :get)
      json = fetch(paths:, query: T.must(query).merge({ format: :json }), method:)
      JSON.parse(T.must(json))
    end

    sig { params(base: String, paths: T::Array[String]).returns(URI::Generic) }
    def join_paths(base, *paths)
      URI.parse(T.must(([base] + paths).reduce { File.join(_1, _2) }))
    end
  end
end
