require "optparse"

require_relative "../consolidate"
require_relative "version"

module Gem
  module Consolidate
    class CLI
      attr_accessor :options

      def initialize
        @options = {}
      end

      USAGE = 'consolidate [options]... <file>'
      DESC = "Consolidates a gem into a single file by replacing require\n" \
             "    statements with the file contents; prints to stdout."
      HELP = <<~B.freeze
        Usage:
            #{USAGE}

        About:
            #{DESC}

        Options:
            --footer=TEXT    append TEXT at end of file
            --header=TEXT    append TEXT at beginning of file
            --no-stdlib      comment out stdlib `require`s
            -h, --help       print this help
            -V, --version    show the version
      B

      def self.parse!
        abort "missing input file" unless ARGV.first
        new.parse!
      rescue OptionParser::MissingArgument, OptionParser::InvalidOption => e
        abort ">>", e.message
      end

      def parse!
        option_parser.parse!
        options
      end

      private

      # @return [OptionParser]
      #
      def option_parser
        @option_parser ||= OptionParser.new do |opts|
          opts.on "-h", "--help" do
            puts HELP
            exit 2
          end

          opts.on "-V", "--version" do
            puts "consolidate v#{Gem::Consolidate::VERSION}"
            exit 2
          end

          opts.on "--footer=text" do |text|
            options[:footer] = text
          end

          opts.on "--header=text" do |text|
            options[:header] = text
          end
        end
      end
    end
  end
end
