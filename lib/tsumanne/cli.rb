# typed: strict

# frozen_string_literal: true

module Tsumanne
  class CLI
    extend T::Sig
    sig { params(args: BasicObject).returns(NilClass) }
    def self.start(args)
      p args
    end
  end
end
