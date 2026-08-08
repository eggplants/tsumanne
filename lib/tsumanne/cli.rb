# typed: strict

# frozen_string_literal: true

module Tsumanne
  # Command line entry point for the `tsumanne` executable.
  class CLI
    extend T::Sig

    sig { params(args: T::Array[String]).void }
    def self.start(args)
      p args
    end
  end
end
