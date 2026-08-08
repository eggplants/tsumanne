# typed: strict

# frozen_string_literal: true

require "json"
require "uri"

require "optimist"
require "sorbet-runtime"

require_relative "../tsumanne"

module Tsumanne
  # Command line entry point for the `tsumanne` executable.
  class CLI
    extend T::Sig

    # Subcommands, in the order `--help` lists them.
    COMMANDS = T.let({
      "threads" => "List the archived threads of a board",
      "thread" => "Print an archived thread, by id or by archive path",
      "search" => "Find the archived thread of a 2chan.net thread URI",
      "indexes" => "List the indexes, or search them by keyword",
      "register" => "Ask the site to archive a 2chan.net thread"
    }.freeze, T::Hash[String, String])

    # Runs `args` as a command line and returns the exit status the executable should exit with.
    sig { params(args: T::Array[String]).returns(Integer) }
    def self.start(args)
      new(args).run
    end

    sig { params(args: T::Array[String]).void }
    def initialize(args)
      @args = T.let(args.dup, T::Array[String])
      # Reassigned to the subcommand parser, so that `--help` educates about the command at hand.
      @parser = T.let(global_parser, Optimist::Parser)
    end

    sig { returns(Integer) }
    def run
      execute
      0
    rescue Optimist::HelpNeeded
      @parser.educate($stdout)
      0
    rescue Optimist::VersionNeeded
      $stdout.puts(@parser.version)
      0
    rescue Optimist::CommandlineError, URI::InvalidURIError, Error => e
      warn("Error: #{e.message}")
      1
    end

    private

    sig { void }
    def execute
      options = @parser.parse(@args)
      # `stop_on` leaves the command and everything after it in `@args`.
      command = @args.shift
      raise Optimist::HelpNeeded if command.nil?
      raise Error, "unknown command `#{command}`" unless COMMANDS.key?(command)

      run_command(command, API.new(board_id: options[:board].to_sym))
    end

    sig { params(command: String, api: API).void }
    def run_command(command, api)
      case command
      when "threads" then threads(api)
      when "thread" then thread(api)
      when "search" then search(api)
      when "indexes" then indexes(api)
      else register(api)
      end
    end

    sig { params(api: API).void }
    def threads(api)
      options = parse_command("threads [options]") do |parser|
        parser.opt(:index, "Index (category) to list", type: :string, default: "all")
        parser.opt(:page, "Page to list", type: :integer, default: 1)
      end
      print_json(api.get_threads(index: options[:index], page: options[:page]))
    end

    sig { params(api: API).void }
    def thread(api)
      parse_command("thread [options] <thread id | archive path>")
      target = operand("`thread` needs a thread id or an archive path")
      $stdout.puts(/\A\d+\z/.match?(target) ? api.get_thread_mht(target) : thread_from_path(api, target))
    end

    sig { params(api: API, target: String).returns(String) }
    def thread_from_path(api, target)
      api.get_thread_from_path(target) ||
        raise(Error, "`#{target}` is not an archive path (expected `YYYY/MM/DD/<thread id>`)")
    end

    sig { params(api: API).void }
    def search(api)
      parse_command("search [options] <thread uri>")
      print_json(api.search_thread_from_uri(URI.parse(operand("`search` needs a 2chan.net thread URI"))))
    end

    sig { params(api: API).void }
    def indexes(api)
      options = parse_command("indexes [options]") do |parser|
        parser.opt(:keyword, "Keyword to search the indexes for", type: :string)
        parser.opt(:order, "Order to list the indexes in",
                   type: :string, default: "newer", permitted: INDEXES_ORDERS.keys.map(&:to_s))
        parser.opt(:page, "Page to list", type: :integer, default: 1)
      end
      print_json(api.search_indexes(keyword: options[:keyword], order: options[:order].to_sym, page: options[:page]))
    end

    sig { params(api: API).void }
    def register(api)
      options = parse_command("register [options] <thread uri>") do |parser|
        parser.opt(:index, "Index (category) to file the thread under, repeatable", type: :string, multi: true)
      end
      uri = URI.parse(operand("`register` needs a 2chan.net thread URI"))
      print_json(api.register_thread(uri, indexes: options[:index]))
    end

    sig { returns(Optimist::Parser) }
    def global_parser
      parser = Optimist::Parser.new
      parser.usage("[global options] <command> [options] [arguments]")
      parser.version("tsumanne #{VERSION}")
      parser.opt(:board, "Board to talk to",
                 type: :string, default: "img", permitted: BOARD_IDS.keys.map(&:to_s))
      # Declared here so that `--help` lists them above the command list, instead of below it.
      parser.opt(:version, "Print version and exit")
      parser.opt(:help, "Show this message")
      parser.stop_on(COMMANDS.keys)
      parser.text("")
      parser.text("Commands:")
      COMMANDS.each { |name, description| parser.text(format("  %-8<name>s  %<description>s", name:, description:)) }
      parser
    end

    # Parses the options of the command at hand, leaving its operands in `@args`.
    sig { params(usage: String, blk: T.nilable(T.proc.params(parser: Optimist::Parser).void)).returns(T.untyped) }
    def parse_command(usage, &blk)
      parser = Optimist::Parser.new
      parser.usage("[global options] #{usage}")
      blk&.call(parser)
      @parser = parser
      parser.parse(@args)
    end

    sig { params(message: String).returns(String) }
    def operand(message)
      @args.shift || raise(Error, message)
    end

    sig { params(response: T::Struct).void }
    def print_json(response)
      $stdout.puts(JSON.generate(response.serialize))
    end
  end
end
