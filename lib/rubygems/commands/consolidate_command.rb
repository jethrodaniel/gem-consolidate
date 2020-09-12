require_relative "../../consolidate"

require "rubygems/command"

class Gem::Commands::ConsolidateCommand < ::Gem::Command
  def initialize
    super "consolidate", "consolidate a Ruby script or gem, print to stdout"

    add_option "--footer=FOOTER", "text to append at end of file" do |footer|
      options[:footer] = footer
    end

    add_option "--header=HEADER", "text to append at beginning of file" do |header|
      options[:header] = header
    end

    add_option "--no-stdlib", "remove stdlib `require`s (for MRuby)" do |bool|
      options[:no_stdlib] = !bool
    end
  end

  def usage
    "#{program_name} {GEM,FILE} [options...]"
  end

  def description
    <<~MSG
      Consolidates a gem into a single file by replacing require statements
      with the file contents; prints to stdout.

      Note:

        - only `require_relative` supported
        # - gem entry **must** by <your_gem/lib/your_gem.rb>
        - only recognizes the literal `require`s, i.e, no `send(:require, "lib")`
    MSG
  end

  def arguments
    "GEM, FILE\tname of gem or path of the script to consolidate"
  end

  def execute
    name = options[:args].first
    raise Gem::CommandLineError, "missing GEM or FILE" unless name

    Consolidate::Consolidator.new(
      name,
      **options.slice(:header, :footer, :stdlib)
    ).run
  end
end
