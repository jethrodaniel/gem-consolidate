require_relative "require_resolver"

module Consolidate
  VERSION = "0.0.1".freeze

  class Consolidator
    def initialize entry, **opts
      @entry  = entry
      @header = opts[:header]
      @footer = opts[:footer]
      @stdlib = opts[:stdlib]
      @location = File.join(Dir.pwd, File.dirname(entry))

      if gemspec = ::Gem.loaded_specs[entry]
        warn "Consolidating gem #{gemspec.name}..."
        raise "gem not supported yet"
      elsif File.file?(entry)
        warn "Consolidating script `#{entry}`..."
      else
        raise Error, "gem or script `#{name}` not found"
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

      puts RequireResolver.new(@entry, :location => @location).run

      # [@header, single_file, @footer].join("\n").strip
    end
  end
end
