# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

# Response of `GET /<board_id>/indexes.php`, a keyword search over the indexes.
class SearchIndexesResponse < T::Struct
  extend T::Sig

  # A single index (category) tag matched by the search.
  class Tag < T::Struct
    extend T::Sig

    const :tag, String
  end

  const :success, T::Boolean
  const :messages, T.nilable(T::Array[String])
  # `null` when listing every index instead of searching for one.
  const :count, T.nilable(Integer)
  const :lastpage, Integer
  const :tags, T::Array[Tag]
end
