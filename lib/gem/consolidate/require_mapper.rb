#require "pathname"
#require "parser/current"
#require "ast"

#require_relative "stdlib"
#require_relative "error"

#module Gem
#  module Consolidate
#    class RequireResolver < Parser::TreeRewriter

#      class Error < Gem::Consolidate::Error; end

#      def initialize file:, paths:
#        super()
#        @file = file
#        @paths = paths
#        @files = []
#      end

#      def run
#        @parser   = Parser::CurrentRuby.new
#        @buffer   = Parser::Source::Buffer.new("(#{@file})")
#        @buffer.source = File.read(@file)

#        ast = @parser.parse(@buffer)
#        out = rewrite(@buffer, ast)
#        require 'pry';require 'pry-byebug';binding.pry;nil
#        puts

#        {Pathname.new(@file) => @files}
#      end

#      # @note Has to be public for Parser::TreeRewriter to do its thing
#      def on_send node
#        req_type = node.children[1]

#        return unless %i[require require_relative].include?(req_type)

#        warn "object to `#{req_type}` is not a string" unless node.children[2].type == :str

#        lib = node.children[2].children[0]

#        send("handle_#{req_type}", lib, node)
#      end

#      private

#      # $ ruby-parse -e "require 'ast'"
#      # (send nil :require
#      #   (str "ast"))
#      #
#      def handle_require_relative lib, node
#        paths = @paths + [File.dirname(@file)]
#        files = paths.map do |p|
#          Pathname.new(File.join(p, lib)).sub_ext('.rb')
#        end.select { |file| File.file?(file) }.uniq

#            if lib !="gem/consolidate"
#        # require 'pry';require 'pry-byebug';binding.pry;nil
#        # puts
#            end
#        # require 'pry';require 'pry-byebug';binding.pry;nil
#        # puts


#        if files.empty?
#          insert_before(node.location.expression, "# ")
#          insert_before(node.location.expression, "# ")
#          insert_after(node.location.expression, " # resolved previously")
#          return

#        if files.empty?
#          raise Error, "`require_relative \"#{lib}\"`could not be resolved to a file"
#        # elsif stdlib or excluded?
#        end

#        @files += files
#      end
#      alias handle_require handle_require_relative
#    end
#  end
#end
