# == gem-consolidate
#
# Consolidate a gem into a single Ruby source file by resolving `require`
# statements, like the C preprocessor's `#include`.
#
# === Topological Sorting
#
# We have a bunch of source files, and we want to resove the dependencies
# by pasting them in.
#
# For example, if file `a.rb` requires `b`, then `c`, we'd say
#
# ```
# a.rb <-- require -- b.rb
#      <-- require -- c.rb
# ```
#
# How do we compile them into a single file?
#
# The ?straightforward? approach is to start with a single file, and recursively
# resolve the inclusions as we go, keeping track of those we've already seen,
# so as to not repeat ourselves.
#
# --- scrap?
#
# We can also model this as a directed graph, where files are vertices, and
# the `require` statements are the edges.
#
# To resolve the dependencies, we want to visit every vertice at least
# once, making sure that all of a vertice's edges have been visited
# before the vertice is visited.
#
# The order in which we visit the vertices is the order in which we
# should "visit" the dependencies when assembling our single-file.
# ---


require "pathname"
require "parser/current"

require_relative "stdlib"
require_relative "error"

module Gem
  module Consolidate
    class RequireResolver < Parser::TreeRewriter
      class Error < Gem::Consolidate::Error; end

      def initialize file:, **opts
        super()

        @file     = file
        @visited  = opts[:visited] || []
        @curr_dir = opts[:curr_dir] || Pathname.new(File.dirname(file))
        @indent   = opts[:indent] || 0

        @skipped = opts[:skipped] || []
        @files << File.absolute_path(@file)

        @parser   = Parser::CurrentRuby.new
        @buffer   = Parser::Source::Buffer.new("(#{file})")
        @buffer.source = File.read(file)
      end

      def run
        ast = @parser.parse(@buffer)
        rewrite(@buffer, ast)
      end

      # $ ruby-parse -e "require 'ast'"
      # (send nil :require
      #   (str "ast"))
      #
      # @note Has to be public for Parser::TreeRewriter to do its thing
      #
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
