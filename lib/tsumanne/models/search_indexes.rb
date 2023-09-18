# typed: strict

require "sorbet-runtime"

class SearchIndexesResponse < T::Struct
  extend T::Sig

  class Tag < T::Struct
    extend T::Sig

    const :tag, String
  end

  const :success, T::Boolean
  const :messages, T::Array[String]
  const :count, Integer
  const :tags, T::Array[Tag]
end
