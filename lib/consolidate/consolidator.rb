require_relative "require_resolver"

module Consolidate
  VERSION = "0.0.1".freeze

  class Error < StandardError; end

  # todo: setup so that this can be called and tested without `gem`.
  #
  # Something like
  #
  #     Consolidate::Consolidator.start
  #
  # Which uses ARGV and parses its own args.
  #
  # optparse is too heavy, as it uses regular expressions. It'd be nice if this
  # could work on MRuby.
  #
  class Consolidator
    def initialize entry, **opts
      @entry  = entry
      @header = opts[:header]
      @footer = opts[:footer]
      @stdlib = opts[:stdlib]
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
      puts @header if @header
      puts @footer if @footer

      # [@header, single_file, @footer].join("\n").strip
    end

    private

    def content
    end

    def body
      RequireResolver.new(
        @entry,
        :location => @location,
        :files => @files
      ).run
    end
  end
end
