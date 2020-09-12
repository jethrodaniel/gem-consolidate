require_relative "require_resolver"

module Consolidate
  class Consolidator
    def initialize entry, **opts
      # @parser = Parser::CurrentRuby.new
      @entry  = entry
      @header = opts[:header]
      @footer = opts[:footer]
      @stdlib = opts[:stdlib]

      if gemspec = ::Gem.loaded_specs[entry]
        warn "Consolidating gem #{gemspec.name}..."
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
      RequireResolver.new(@entry)
      # single_file = consolidator.consolidate(@gem_entry, @parser, @files, :no_stdlib => @no_stdlib)
      # [@header, single_file, @footer].join("\n").strip
    end
  end
end
