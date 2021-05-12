require_relative "../../gem-consolidate"

require "rubygems/command"

class Gem::Commands::ConsolidateCommand < ::Gem::Command
  def initialize
    super "consolidate"

    add_option "--no-stdlib" do |bool|
      options[:include_stdlib] = bool
    end

    add_option "--exclude=LIBS" do |libs|
      options[:exclude] = libs.split(',')
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
    fix_argv!
    name = ARGV.first
    abort "missing gem NAME" unless name

    opts = {
      include_stdlib: options[:include_stdlib],
      exclude: options[:exclude],
      name: name,
    }.compact

    Gem::Consolidate::Consolidator.new(**opts).run!
  end

  private

  def fix_argv!
    ARGV.shift # rm `consolidate`
    ARGV.delete_if do |e|
     %w[--exclude --no-stdlib].any? { |opt| e.start_with?(opt) }
    end
  end
end
