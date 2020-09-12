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
  def initialize file
    super()

    @file  = Pathname.new(file)
    @root  = @file.dirname
    @files = [@file]
    buffer = Parser::Source::Buffer.new("(#{file})")
    buffer.source = File.read(file)
    parser = Parser::CurrentRuby.new
    # parser = parser.tap(&:reset)
    ast = parser.parse(buffer)

    puts "#" + "-"* 60 + "\n"
    puts <<~MSG
      # Automatically consolidated from `require` and
      # `require_relative` calls.
      #
      # ruby  : #{RUBY_VERSION}
      # parser: #{Parser::VERSION}
      #
      # entry point: `#{file}`
    MSG
    puts "#" + "-"* 60 + "\n"
    puts rewrite(buffer, ast)
  end

  # @note Has to be public for Parser::TreeRewriter to do its thing
  def on_send node
    req_type = node.children[1]

    return unless %i[require require_relative].include?(req_type)

    warn "object to `#{req_type}` is not a string" unless node.children[2].type == :str

    send("handle_#{req_type}", node)
  end

  private

  # $ ruby-parse -e "require 'ast'"
  # (send nil :require
  #   (str "ast"))
  #
  def handle_require_relative node
    lib = node.children[2].children[0]

    if stdlib?(lib)
      warn "=> #{lib} (stdlib)"
      remove(node.location.expression) if @no_stdlib
      return
    end

    if @files.include?(lib)
      warn "=> #{lib} (already seen)"
      puts "# #{lib}"
      remove(node.location.expression)
      return
    end
    @files << lib

    warn "=> #{lib}"
    # consolidator = RequireResolver.new
    # req_contents = consolidator.consolidate(req_file, @parser, @files, :no_stdlib => @no_stdlib)

    # TODO: what order does Ruby use here?
    file = Dir.glob("#{@root + lib}.{rb,so}").first

    replacement = File.read(file)
    banner = "#" + "-"*60 + "\n# #{file}\n#" + "-" * 60 + "\n"
    replacement = banner + replacement + "#" + "-" * 60 + "\n"

    replace node.location.expression, "\n#{replacement.strip}\n"
  end

  def stdlib? lib
    Consolidate::STD_LIBS.include? lib
  end
end
