require "rubygems/consolidate/command"
require "rubygems/consolidate/consolidate"

class Gem::Commands::ConsolidateCommand < Gem::Consolidate::Command
  def initialize
    super "consolidate", "consolidate a gem, print to stdout"

    add_option "--footer=FOOTER", "text to append at end of file" do |footer, _opts|
      options[:footer] = footer
    end

    add_option "--header=HEADER", "text to append at beginning of file" do |header, _opts|
      options[:header] = header
    end

    add_option "--no-stdlib", "remove stdlib `require`s (for MRuby)" do |bool|
      options[:no_stdlib] = !bool
    end
  end

  def usage
    "#{program_name} GEM [options]"
  end

  def description
    <<~MSG
      Consolidates a gem into a single file by replacing require statements
      with the file contents; prints to stdout.

      Note:

        - no `require_relative` support
        - gem entry **must** by <your_gem/lib/your_gem.rb>
        - only recognizes the literal `require`s, i.e, no `send(:require, "lib")`
    MSG
  end

  def arguments
    "GEM\tname of gem to consolidate"
  end

  def execute
    name = options[:args].first
    raise Gem::CommandLineError, "missing GEM argument" unless name

    gemspec = Gem::Specification.find_by_name(options[:args].first)
    warn "Consolidating gem #{gemspec.name}..."

    # @todo: find entry point the _right_ way: https://github.com/rubygems/rubygems/blob/master/lib/rubygems/commands/which_command.rb
    entry_point = File.join(gemspec.gem_dir, "lib/#{gemspec.name}.rb")

    puts GemConsolidator.new(
      entry_point,
      :header    => options[:header],
      :footer    => options[:footer],
      :no_stdlib => options[:no_stdlib]
    ).run
  end
end
