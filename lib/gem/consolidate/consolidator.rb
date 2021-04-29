require "pathname"

require_relative "require_resolver"
require_relative "require_mapper"
require_relative "version"
require_relative "error"

module Gem
  module Consolidate
    class Consolidator
      class Error < Consolidate::Error; end

      def initialize **opts
        if gemspec = opts[:gem]
          @files = gemspec.files
                          .map do |f|
                            gemspec.full_require_paths
                                   .map do |dir|
                                     File.join(dir, f.delete_prefix(File.basename(dir)))
                                   end
                          end.flatten.uniq.select { |f| File.file?(f) }
          @paths = gemspec.full_require_paths

require 'pry';require 'pry-byebug';binding.pry;nil
puts

          dependencies = @files.map do |file|
            t = RequireResolver.new(file: file, paths: @paths).run
          end
          require 'pry';require 'pry-byebug';binding.pry;nil
          puts

        elsif file = opts[:file]
        else
          raise Error, "missing `gem` or `file`"
        end

        @header = opts[:header]
        @footer = opts[:footer]
        @skipped = opts[:skipped] || []
        @skipped += Consolidate::STD_LIBS
        @location = Pathname.new(Dir.pwd) + File.dirname(entry)
        @files = []
      end

      def run
        warn "Consolidating gem `#{gemspec.name}`..."
        warn "Consolidating script `#{entry}`..."

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
