# typed: strict

# frozen_string_literal: true

require "sorbet-runtime"

require_relative "tsumanne/api"
require_relative "tsumanne/version"

# API module for tsumanne.net includes knowledge as const.
module Tsumanne
  extend T::Sig

  # API endpoint of tsumanne.net.
  BASE_URL = "https://tsumanne.net/"

  # Valid Board Identifiers.
  BOARD_IDS = T.let({ img: "si", may: "my", jun: "tj", dat: "sa", special: "sp" }.freeze, T::Hash[Symbol, String])
  # Corresponing orders to list indexes. (`index` is same as `category`)
  INDEXES_ORDERS = T.let({ hira: "↓あ", newer: "↓新" }.freeze, T::Hash[Symbol, String])

  class Error < StandardError; end
end
