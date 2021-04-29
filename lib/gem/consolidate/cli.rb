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
            --exclude=LIBS   list of libraries to skip
            -h, --help       print this help
            -V, --version    show the version
      B

      def self.parse! entry
        abort "missing input file" unless entry
        new.parse!(entry)
      rescue OptionParser::MissingArgument, OptionParser::InvalidOption => e
        abort ">>", e.message
      end

      def parse! entry
        option_parser.parse!
        options.merge(parse_entry!(entry))
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

          opts.on "--no-stdlib" do
            options[:no_stdlib] = false
          end

          opts.on "--footer=text" do |text|
            options[:footer] = text
          end

          opts.on "--header=text" do |text|
            options[:header] = text
          end

          opts.on "--exclude=LIBS", Array do |libs|
            options[:skipped] = libs
          end
        end
      end

      # @param entry [String] file or gem name
      # @return opts [Hash]
      #   :gem [Symbol] the path to the gemspec, if found
      #   :file [Symbol] the full path of the file, if found
      # @raises [Error] if the gem or file can't be found
      #
      def parse_entry! entry
        if gemspec = ::Gem.loaded_specs[entry]
          {gem: gemspec}
        elsif File.file? entry
          {file: File.absolute_path(entry)}
        else
          raise Error, "gem or script `#{entry}` not found"
        end
      end
    end
  end
end
