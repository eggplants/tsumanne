# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

# Response of `POST /<board_id>/input.php`, the thread registration endpoint.
class RegisterThreadResponse < T::Struct
  extend T::Sig

  # Result of attaching the requested categories to the registered thread.
  class Tags < T::Struct
    extend T::Sig

    const :success, T::Boolean
    const :messages, T::Array[String]
  end

  const :success, T::Boolean
  const :messages, T::Array[String]
  # Only returned when the request actually attached categories.
  const :tags, T.nilable(Tags)
end
