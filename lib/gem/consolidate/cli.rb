require "optparse"

require_relative "../consolidate"
require_relative "version"

module Gem
  module Consolidate
    module CLI
      BANNER = <<~B.freeze
        Usage:
            consolidate [options]... [file|gem]...

        Options:
      B

      def self.parse!
        self.handle_options!
        abort "input file or gem not provided" unless f = ARGV.first
      end

      # @return [OptionParser]
      def self.option_parser
        OptionParser.new do |opts|
          opts.on "-h", "--help", "print this help" do
            puts opts
            exit 2
          end

          opts.on "-V", "--version", "show the version" do
            puts "consolidate version #{Gem::Consolidate::VERSION}"
            exit 2
          end
        end
      end

      def self.handle_options!
        option_parser.parse!
      rescue OptionParser::MissingArgument, OptionParser::InvalidOption => e
        abort e.message
      end
    end
  end
end
