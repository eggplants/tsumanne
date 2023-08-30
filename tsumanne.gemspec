# frozen_string_literal: true

require_relative "lib/tsumanne/version"

Gem::Specification.new do |spec|
  spec.name = "tsumanne"
  spec.version = Tsumanne::VERSION
  spec.authors = ["eggplants"]
  spec.email = ["w10776e8w@yahoo.co.jp"]

  spec.summary = "API Wrapper for tsumanne.net"
  spec.description = "This gem provide unofficial API of tsumanne.net, an aggregation site of 2chan.net, in Ruby"
  spec.homepage = "https://github.com/eggplants/tsumanne"
  spec.license = "MIT"
  spec.required_ruby_version = "~> 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mhtml", "~> 0.1"
  spec.add_dependency "sorbet-runtime", "~> 0.5"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_development_dependency "sorbet", "~> 0.5"
  spec.add_development_dependency "tapioca", "~> 0.11"

  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "rubocop-sorbet", "~> 0.7"
  spec.add_development_dependency "rubocop-rake", "~> 0.6"
  spec.add_development_dependency "rubocop-rspec", "~> 2.23"
  spec.add_development_dependency "rubocop-performance", "~> 1.19"
end
