require_relative "../../gem/consolidate"

require "rubygems/command"

class Gem::Commands::ConsolidateCommand < ::Gem::Command
  def initialize
    super "consolidate", "consolidate a Ruby script, print to stdout"

    add_option "--footer=FOOTER", "text to append at end of file" do |footer|
      options[:footer] = footer
    end

    add_option "--header=HEADER", "text to append at beginning of file" do |header|
      options[:header] = header
    end

    add_option "--no-stdlib", "comment out stdlib `require`s (for MRuby)" do |bool|
      options[:no_stdlib] = !bool
    end
  end

  def usage
    Gem::Consolidate::CLI::USAGE
  end

  def description
    Gem::Consolidate::CLI::DESC
  end

  def execute
    name = options[:args].first
    raise Gem::CommandLineError, "missing input file" unless name

    Gem::Consolidate::Consolidator.new(
      name,
      **options.slice(:header, :footer, :stdlib)
    ).run
  end
end
