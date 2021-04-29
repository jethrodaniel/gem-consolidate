require_relative "../../gem/consolidate"

require "rubygems/command"

class Gem::Commands::ConsolidateCommand < ::Gem::Command
  def initialize
    super "consolidate"

    add_option "--footer=FOOTER" do |footer|
      options[:footer] = footer
    end

    add_option "--header=HEADER" do |header|
      options[:header] = header
    end

    add_option "--no-stdlib" do |bool|
      options[:no_stdlib] = !bool
    end

    add_option "--exclude=LIBS" do |libs|
      options[:skipped] = libs.split(',')
    end
  end

  def usage
    Gem::Consolidate::CLI::USAGE
  end

  def description
    Gem::Consolidate::CLI::DESC
  end

  def execute
    opts = CLI.parse! options[:args].first
    Consolidator.new(**opts).run
  end
end
