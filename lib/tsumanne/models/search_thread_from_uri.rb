# typed: strict

require "sorbet-runtime"

class SearchThreadFromUriResponse < T::Struct
  extend T::Sig

  const :success, T::Boolean
  const :messages, T::Array[String]
  const :path, String
end
