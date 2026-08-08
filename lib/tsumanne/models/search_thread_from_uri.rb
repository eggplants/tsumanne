# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

# Response of `GET /<board_id>/indexes.php?sbmt=URL`, a lookup of archived threads by their source URI.
class SearchThreadFromUriResponse < T::Struct
  extend T::Sig

  # An archived thread whose source URI matched the query.
  class Log < T::Struct
    extend T::Sig

    const :id, Integer
    const :url, String # URI
    const :path, String
    const :category, T::Array[String]
  end

  const :success, T::Boolean
  const :logs, T::Array[Log]
  const :messages, T.nilable(T::Array[String])
end
