# typed: strict

# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

require "sorbet-runtime"

require_relative "models/get_threads"
require_relative "models/search_thread_from_uri"
require_relative "models/search_indexes"
require_relative "models/register_thread"

# API module for tsumanne.net includes knowledge as const.
module Tsumanne
  # Client for the tsumanne.net endpoints of a single board.
  class API
    extend T::Sig

    sig { returns(String) }
    attr_reader :board_id

    sig { params(board_id: Symbol).void }
    def initialize(board_id:)
      @board_id = T.let(T.must(BOARD_IDS[board_id]), String)
    end

    sig { params(index: String, page: Integer).returns(GetThreadsResponse) }
    def get_threads(index: "all", page: 1)
      # https://tsumanne.net/si/all/1
      # https://tsumanne.net/si/hoge/1
      GetThreadsResponse.from_hash(fetch_json(paths: [index, page.to_s]))
    end

    # Returns the merged HTML export of an archived thread, as served by the site (Shift_JIS encoded).
    #
    # `mht.php` used to answer with JSON pointing at a gzipped MHTML file; it now redirects straight
    # to a single self-contained HTML document, so no MHTML parsing is involved anymore.
    sig { params(thread_id: String).returns(String) }
    def get_thread_mht(thread_id)
      # https://tsumanne.net/si/mht.php?id=129691 -> 302 ./mhttmp/86279902.html
      uri = join_paths(BASE_URL, [@board_id, "mht.php"])
      uri.query = URI.encode_www_form({ id: thread_id })
      res = Net::HTTP.get_response(uri)
      raise Error, "thread #{thread_id} is not archived (HTTP #{res.code})" unless res.is_a?(Net::HTTPRedirection)

      T.must(Net::HTTP.get(URI.join(uri, res["location"])))
    end

    sig { params(thread_path: String).returns(T.nilable(String)) }
    def get_thread_from_path(thread_path)
      # https://tsumanne.net/si/data/2023/08/30/8883354/
      match_data = %r{^\d{4}/\d{2}/\d{2}/(?<thread_id>\d+)$}.match(thread_path)
      return if match_data.nil?

      get_thread_mht(T.must(match_data[:thread_id]))
    end

    sig { params(uri: URI).returns(SearchThreadFromUriResponse) }
    def search_thread_from_uri(uri)
      # https://tsumanne.net/si/indexes.php?format=json&w=...&sbmt=URL
      # https://tsumanne.net/si/indexes.php?format=json&w=https%3A%2F%2Fimg.2chan.net%2Fb%2Fres%2F86279902.htm&sbmt=URL
      SearchThreadFromUriResponse.from_hash(
        fetch_json(paths: ["indexes.php"], query: { w: uri, sbmt: :URL })
      )
    end

    sig { params(keyword: T.nilable(String), order: Symbol, page: Integer).returns(SearchIndexesResponse) }
    def search_indexes(keyword: nil, order: :newer, page: 1)
      # https://tsumanne.net/si/indexes.php?format=json&w=&sbmt=%E2%86%93%E6%96%B0
      SearchIndexesResponse.from_hash(
        fetch_json(paths: ["indexes.php"], query: { w: keyword, sbmt: INDEXES_ORDERS[order], p: page })
      )
    end

    sig { params(uri: URI, indexes: T.nilable(T::Array[String])).returns(RegisterThreadResponse) }
    def register_thread(uri, indexes: nil)
      # post, https://tsumanne.net/si/input.php?format=json&url=...&category=...
      RegisterThreadResponse.from_hash(
        fetch_json(paths: ["input.php?format=json"], query: { url: uri, category: (indexes || []).join(",") },
                   method: :post)
      )
    end

    private

    sig do
      params(paths: T.nilable(T::Array[String]),
             query: T.nilable(T::Hash[Symbol, T.any(Integer, String, Symbol)]),
             method: Symbol).returns(T.nilable(String))
    end
    def fetch(paths: nil, query: nil, method: :get)
      uri = join_paths(BASE_URL, [@board_id] + (paths || []))
      query = URI.encode_www_form(query || {})

      case method
      when :get
        uri.query = query
        Net::HTTP.get(uri)
      when :post
        # Without an explicit form content type the server does not populate `$_POST`,
        # and answers with a PHP warning followed by a "not permitted URL" error.
        Net::HTTP.post(uri, query, "Content-Type" => "application/x-www-form-urlencoded").body
      end
    end

    sig do
      params(paths: T.nilable(T::Array[String]),
             query: T.nilable(T::Hash[Symbol, T.any(Integer, String, Symbol)]),
             method: Symbol).returns(T::Hash[String, T.untyped])
    end
    def fetch_json(paths: nil, query: nil, method: :get)
      query ||= {}
      json = fetch(paths:, query: query.merge({ format: :json }), method:)
      JSON.parse(T.must(json))
    end

    sig { params(base: String, paths: T::Array[String]).returns(URI::Generic) }
    def join_paths(base, *paths)
      URI.parse(T.must(([base] + paths).reduce { |joined, path| File.join(joined, path) }))
    end
  end
end
