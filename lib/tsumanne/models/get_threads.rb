# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

# Response of `GET /<board_id>/<index>/<page>`, a page of archived threads.
class GetThreadsResponse < T::Struct
  extend T::Sig

  # A single archived thread listed on the page.
  class Log < T::Struct
    extend T::Sig

    const :id, Integer
    const :url, String # URI
    const :date, String # Time
    const :close, T::Boolean
    const :res, Integer
    const :files, Integer
    # Only some boards report this one.
    const :access, T.nilable(Integer)
    const :text, String
    const :thumb, String
    # `public` and `del` are no longer part of the response; kept for older archives.
    const :public, T.nilable(T::Boolean)
    const :del, T.nilable(Integer)
    const :atid, T::Boolean
    const :last, String # Time
    const :path, String
    const :category, T::Array[String]
  end

  const :success, T::Boolean
  const :messages, T::Array[String]
  const :lastpage, Integer
  const :count, Integer
  const :cid, Integer
  const :logs, T::Array[Log]
end
