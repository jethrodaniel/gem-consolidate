require_relative "../../gem-consolidate"

require "rubygems/command"

class Gem::Commands::ConsolidateCommand < ::Gem::Command
  def initialize
    super "consolidate"

    add_option "--no-stdlib" do |bool|
      options[:no_stdlib] = !bool
    end

    add_option "--exclude=LIBS" do |libs|
      options[:skipped] = libs.split(',')
    end
  end

  def usage
    'consolidate [options]... FILE'
  end

  def description
    "Consolidates a gem into a single file by replacing require " \
      "statements with the file contents; prints to stdout."
  end

  def execute
    ARGV.shift # rm `consolidate`
    Gem::Consolidate::Consolidator.new(**options).run!
  end
end
