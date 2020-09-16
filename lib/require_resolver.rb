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

    @file     = Pathname.new(file)
    @location = opts[:location] || Pathname.new(Dir.pwd)
    @files    = opts[:files]    || [@file]
    @parser   = Parser::CurrentRuby.new
    @buffer   = Parser::Source::Buffer.new("(#{file})")
    @buffer.source = File.read(file)
  end

  def run
    ast = @parser.parse(@buffer)
    out = rewrite(@buffer, ast)
    out.split("\n").join("\n") + "\n"
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

      insert_before(node.location.expression, "# ")
      insert_after(node.location.expression, " # stdlib excluded")
      # remove(node.location.expression)
      return
    end

    if @files.include?(lib)
      warn "=> #{lib} (already seen)"
      # puts "# #{lib}"
      # insert_before(node.location.expression, "# ")
      insert_before(node.location.expression, "# ")
      insert_after(node.location.expression, " # resolved previously")
      return
    end

    warn "=> #{lib}"

    # TODO: what order does Ruby use here?
    file = Dir.glob("#{@location + lib}.{rb,so}").first

    raise Error, "#{file} not found" unless file

    @files << lib

    replacement = RequireResolver.new(
      file,
      :location => Pathname.new(file).dirname
    ).run

    # https://bugs.ruby-lang.org/issues/10011
    pwd = RUBY_VERSION.gsub(".", "").to_i >= 260 ? Dir.pwd : Pathname.new(Dir.pwd)
    f = Pathname.new(file).relative_path_from(pwd).to_s
    banner = "#" + "-"*60 + "\n# #{f}\n#" + "-" * 60 + "\n"
    replacement = banner + replacement + "#" + "-" * 60 + "\n"

    insert_before(node.location.expression, "# ")
    insert_after(node.location.expression, "\n\n#{replacement.strip}\n")
  end
  alias handle_require handle_require_relative

  def stdlib? lib
    Consolidate::STD_LIBS.include? lib
  end
end
