require_relative "../../gem/consolidate"

require "rubygems/command"

class Gem::Commands::ConsolidateCommand < ::Gem::Command
  def initialize
    super "consolidate"
  end

  def usage
    Gem::Consolidate::CLI::USAGE
  end

  def description
    Gem::Consolidate::CLI::HELP
  end

  def execute
    name = options[:args].first
    raise Gem::CommandLineError, "missing input file" unless name

    Gem::Consolidate::Consolidator.new(
      name,
      **options
    ).run
  end
end
