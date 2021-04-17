#------------------------------------------------------------
# Automatically consolidated from `require` and
# `require_relative` calls.
#
# ruby  : 2.7.1
# parser: 3.0.1.0
#
# entry point: `lib/gem/consolidate.rb`
#------------------------------------------------------------
# require_relative "consolidate/consolidator"

#=== start: lib/gem/consolidate/consolidator.rb
require "pathname"

# require_relative "require_resolver"

##=== start: lib/gem/consolidate/require_resolver.rb
# == Consolidate Ruby `require`s into a single file.
#
# In a more general sense, this is a dependency resolution problem.
#
# Let's model the files and their dependencies as a graph,  with vertices for
# each file, and edges for each `require`.
#
# TODO

require "pathname"
require "parser/current"

# require_relative "stdlib"

###=== start: lib/gem/consolidate/stdlib.rb
module Gem
  module Consolidate
    STD_LIBS = %w[
      English
      base64
      digest/md5
      digest/sha1
      digest/sha2
      e2mmap
      fiddle/import
      fileutils
      forwardable
      io/console
      jruby
      logger
      openssl
      ostruct
      optparse
      pathname
      readline
      reline
      ripper
      securerandom
      socket
      stringio
      strscan
      tempfile
      timeout
      win32api
    ].freeze
  end
end
###=== end: lib/gem/consolidate/stdlib.rb

# require_relative "error"

###=== start: lib/gem/consolidate/error.rb
module Gem
  module Consolidate
    class Error < StandardError; end
  end
end
###=== end: lib/gem/consolidate/error.rb


module Gem
  module Consolidate
    class RequireResolver < Parser::TreeRewriter
      class Error < Gem::Consolidate::Error; end

      def initialize file, **opts
        super()

        @file     = Pathname.new(file).realpath
        @location = opts[:location] || Pathname.new(Dir.pwd)
        @files    = opts[:files] || abort("missing files")
        @files << @file.realpath
        @indent   = opts[:indent] || 0
        @skipped  = opts[:skipped] || []
        @parser   = Parser::CurrentRuby.new
        @buffer   = Parser::Source::Buffer.new("(#{file})")
        @buffer.source = File.read(file)
      end

      def run
        ast = @parser.parse(@buffer)
        rewrite(@buffer, ast)
      end

      # @note Has to be public for Parser::TreeRewriter to do its thing
      def on_send node
        req_type = node.children[1]

        return unless %i[require require_relative].include?(req_type)

        warn "object to `#{req_type}` is not a string" unless node.children[2].type == :str

        lib = node.children[2].children[0]

        if @skipped.include?(lib) && req_type == :require
          warn "=> #{lib} (skipped)"
          return
        end

        send("handle_#{req_type}", lib, node)
      end

      private

      # $ ruby-parse -e "require 'ast'"
      # (send nil :require
      #   (str "ast"))
      #
      def handle_require_relative lib, node
        # TODO: what order does Ruby use here?
        file = Dir.glob("#{@location + lib}.{rb,so}").first

        raise Error, "library `#{lib}`could not be resolved to a file" unless file

        file = Pathname.new(file).realpath

        # p @files
        # p file
        if @files.include?(file)
          warn "=> #{lib} (already seen)"
          # puts "# #{lib}"
          # insert_before(node.location.expression, "# ")
          insert_before(node.location.expression, "# ")
          insert_after(node.location.expression, " # resolved previously")
          return
        end

        warn "=> #{lib}"

        replacement = RequireResolver.new(
          file,
          :location => Pathname.new(file).dirname,
          :indent   => @indent + 1,
          :files    => @files,
          :skipped  => @skipped
        ).run

        # https://bugs.ruby-lang.org/issues/10011
        pwd = RUBY_VERSION.gsub(".", "").to_i >= 260 ? Dir.pwd : Pathname.new(Dir.pwd)
        f = Pathname.new(file).relative_path_from(pwd).to_s

        replacement = <<~BANNER
          ##{'#' * @indent}=== start: #{f}
          #{replacement.chomp}
          ##{'#' * @indent}=== end: #{f}
        BANNER

        insert_before(node.location.expression, "# ")
        insert_after(node.location.expression, "\n\n#{replacement.strip}\n")
      end
      alias handle_require handle_require_relative
    end
  end
end
##=== end: lib/gem/consolidate/require_resolver.rb

# require_relative "version"

##=== start: lib/gem/consolidate/version.rb
module Gem
  module Consolidate
    VERSION = "0.1.2".freeze
  end
end
##=== end: lib/gem/consolidate/version.rb

# require_relative "error" # resolved previously

module Gem
  module Consolidate
    class Consolidator
      class Error < Consolidate::Error; end

      def initialize entry, **opts
        @entry  = entry
        @header = opts[:header]
        @footer = opts[:footer]
        @skipped = opts[:skipped] || []
        @skipped += Consolidate::STD_LIBS
        @location = Pathname.new(Dir.pwd) + File.dirname(entry)
        @files = []

        if gemspec = ::Gem.loaded_specs[entry]
          warn "Consolidating gem #{gemspec.name}..."
          raise "gem not supported yet"
        elsif File.file?(entry)
          warn "Consolidating script `#{entry}`..."
        else
          raise Error, "gem or script `#{entry}` not found"
        end
      end

      def self.run entry
        new(entry).run
      end

      def run
        puts @header if @header
        puts "#" + "-" * 60 + "\n"
        puts <<~MSG
          # Automatically consolidated from `require` and
          # `require_relative` calls.
          #
          # ruby  : #{RUBY_VERSION}
          # parser: #{Parser::VERSION}
          #
          # entry point: `#{@entry}`
        MSG
        puts "#" + "-" * 60 + "\n"
        puts body
        puts @footer if @footer

        # [@header, single_file, @footer].join("\n").strip
      end

      private

      def body
        RequireResolver.new(
          @entry,
          :location => @location,
          :files    => @files,
          :skipped  => @skipped
        ).run
      end
    end
  end
end
#=== end: lib/gem/consolidate/consolidator.rb

# require_relative "consolidate/cli"

#=== start: lib/gem/consolidate/cli.rb
require "optparse"

# require_relative "../consolidate" # resolved previously
# require_relative "version" # resolved previously

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
    end
  end
end
#=== end: lib/gem/consolidate/cli.rb


module Gem
  module Consolidate
    def self.start
      opts = CLI.parse!
      Consolidator.new(ARGV.first, **opts).run
    end
  end
end
Gem::Consolidate.start
