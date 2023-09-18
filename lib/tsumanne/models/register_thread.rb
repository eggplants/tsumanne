# typed: strict

require "sorbet-runtime"

class RegisterThreadResponse < T::Struct
  extend T::Sig

  class Tags < T::Struct
    extend T::Sig

    const :success, T::Boolean
    const :messages, T::Array[String]
  end

  const :success, T::Boolean
  const :messages, T::Array[String]
  const :tags, Tags
end
