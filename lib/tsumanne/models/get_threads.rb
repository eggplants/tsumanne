# typed: strict

require "sorbet-runtime"

class GetThreadsResponse < T::Struct
  extend T::Sig

  class Log < T::Struct
    extend T::Sig

    const :id, Integer
    const :url, String # URI
    const :date, String # Time
    const :close, T::Boolean
    const :res, Integer
    const :files, Integer
    const :access, Integer
    const :public, T::Boolean
    const :text, String
    const :thumb, String
    const :del, Integer
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
