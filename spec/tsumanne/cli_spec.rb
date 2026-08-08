# typed: false
# frozen_string_literal: true

require "json"
require "stringio"

require "tsumanne/cli"

# Runs the CLI in-process and collects what a shell would have seen.
module CLIRunner
  # Returns the exit status along with everything written to stdout and stderr.
  def cli(*argv)
    out = StringIO.new
    err = StringIO.new
    original_stdout = $stdout
    original_stderr = $stderr
    $stdout = out
    $stderr = err
    begin
      status = Tsumanne::CLI.start(argv)
    rescue SystemExit => e
      status = e.status
    ensure
      $stdout = original_stdout
      $stderr = original_stderr
    end
    [status, out.string, err.string]
  end
end

RSpec.describe Tsumanne::CLI, :aggregate_failures do
  include CLIRunner

  describe "--help" do
    it "lists every command, without arguments" do
      _status, stdout, _stderr = cli
      expect(stdout).to include(*described_class::COMMANDS.keys)
    end

    # Optimist prefixes the usage line with the program name, which is `rspec` in here.
    it "describes a single command, with --help after it" do
      _status, stdout, _stderr = cli("threads", "--help")
      expect(stdout).to include("[global options] threads [options]")
    end
  end

  describe "--version" do
    it "prints the gem version" do
      _status, stdout, _stderr = cli("--version")
      expect(stdout).to include(Tsumanne::VERSION)
    end
  end

  describe "invalid usage" do
    it "rejects an unknown command" do
      status, _stdout, stderr = cli("bogus")
      expect(status).not_to be_zero
      expect(stderr).to include("unknown command")
    end

    it "rejects an unknown board" do
      status, _stdout, stderr = cli("--board", "nope", "threads")
      expect(status).not_to be_zero
      expect(stderr).to include("--board")
    end

    it "reports a missing operand" do
      status, _stdout, stderr = cli("thread")
      expect(status).to be(1)
      expect(stderr).to include("needs a thread id")
    end
  end

  describe "threads" do
    it "prints the listing as JSON" do
      status, stdout, _stderr = cli("threads", "--page", "2")
      expect(status).to be(0)
      expect(JSON.parse(stdout)).to include("success" => true)
    end

    it "honours the global --board option" do
      status, stdout, _stderr = cli("--board", "may", "threads")
      expect(status).to be(0)
      expect(JSON.parse(stdout)["logs"].first["url"]).to include("may.2chan.net")
    end
  end

  describe "thread" do
    it "prints the archived document, given a thread id" do
      status, stdout, _stderr = cli("thread", "129691")
      expect(status).to be(0)
      expect(stdout).to include("charset=Shift_JIS")
    end

    it "prints the archived document, given an archive path" do
      status, stdout, _stderr = cli("thread", "2010/05/05/129691")
      expect(status).to be(0)
      expect(stdout).to include("charset=Shift_JIS")
    end

    it "fails, given an unparsable path" do
      status, _stdout, stderr = cli("thread", "not/a/path")
      expect(status).to be(1)
      expect(stderr).to include("archive path")
    end

    it "fails, given an unarchived thread id" do
      status, _stdout, stderr = cli("thread", "999999999")
      expect(status).to be(1)
      expect(stderr).to include("not archived")
    end
  end

  describe "search" do
    it "prints the matching thread as JSON" do
      status, stdout, _stderr = cli("search", "https://img.2chan.net/b/res/86279902.htm")
      expect(status).to be(0)
      expect(JSON.parse(stdout)["logs"].first["path"]).to eql("data/2010/05/05/129691")
    end
  end

  describe "indexes" do
    it "prints the indexes as JSON" do
      status, stdout, _stderr = cli("indexes", "--order", "hira")
      expect(status).to be(0)
      expect(JSON.parse(stdout)["tags"]).not_to be_empty
    end

    it "searches the indexes, with --keyword" do
      status, stdout, _stderr = cli("indexes", "--keyword", "深淵")
      expect(status).to be(0)
      expect(JSON.parse(stdout)).to include("success" => true)
    end
  end

  describe "register" do
    it "prints the registration result as JSON" do
      status, stdout, _stderr = cli("register", "https://img.2chan.net/b/res/0.htm", "--index", "test")
      expect(status).to be(0)
      expect(JSON.parse(stdout)).to include("success" => true)
    end
  end
end
