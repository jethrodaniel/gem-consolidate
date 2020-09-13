# == Consolidate Ruby `require`s into a single file.
#
# In a more general sense, this is a dependency resolution problem.
#
# Let's model the files and their dependencies as a graph,  with vertices for
# each file, and edges for each `require`.
#
# ```
# app
# |-- lib
#     |-- foo.rb
#     |-- foo
#     |   `-- bar.rb
#     `-- app.rb
# ```
#
# ```
# app/app.rb  <requires>  app/lib/foo.rb  lib/foo/bar.rb
#  *-------------------------> * --------------> *
# ```
#
#
#

require "pathname"
require "parser/current"

require_relative "stdlib"

class RequireResolver < Parser::TreeRewriter
  def initialize file, **opts
    super()

    @file  = Pathname.new(file)
    @root  = @file.dirname
    @location = opts[:location] || Dir.pwd
    @files = [@file]
    @buffer = Parser::Source::Buffer.new("(#{file})")
    @buffer.source = File.read(file)
    @parser = Parser::CurrentRuby.new
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

    send("handle_#{req_type}", node)
  end

  private

  def parse code
    buffer = Parser::Source::Buffer.new("")
    buffer.source = code
    @parser.reset
    @parser.parse(buffer)
  end

  # $ ruby-parse -e "require 'ast'"
  # (send nil :require
  #   (str "ast"))
  #
  def handle_require_relative node
    lib = node.children[2].children[0]

    if stdlib?(lib)
      warn "=> #{lib} (stdlib)"

      insert_before(node.location.expression, "# ")
      insert_after(node.location.expression, " # stdlib excluded")
      # remove(node.location.expression)
      return
    end

    if @files.include?(lib)
      warn "=> #{lib} (already seen)"
      # puts "# #{lib}"
      # insert_before(node.location.expression, "# ")
      # remove(node.location.expression)
      insert_before(node.location.expression, "# ")
      insert_after(node.location.expression, " # resolved previously")
      return
    end
    @files << lib

    warn "=> #{lib}"

    # TODO: what order does Ruby use here?
    file = Dir.glob("#{File.join(@location, lib)}.{rb,so}").first

    unless file
      insert_before(node.location.expression, "# ")
      insert_after(node.location.expression, " # resolved previously")
      return
    end

    # replacement = File.read(file)
    # replacement = parse(File.read(file))
    replacement = RequireResolver.new(
      file,
      :location => @location + lib
    ).run

    f = Pathname.new(file).relative_path_from(Dir.pwd).to_s
    banner = "#" + "-"*60 + "\n# #{f}\n#" + "-" * 60 + "\n"
    replacement = banner + replacement + "#" + "-" * 60 + "\n"

    replace node.location.expression, "\n#{replacement.strip}\n"
  end
  alias handle_require handle_require_relative

  def stdlib? lib
    Consolidate::STD_LIBS.include? lib
  end
end
