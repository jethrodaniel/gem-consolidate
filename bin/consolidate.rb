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

class RequireResolver < Parser::TreeRewriter
  STD_LIBS = %w[
    English
    logger
    reline
    e2mmap
    ripper
    fileutils
    jruby
    readline
    io/console
    timeout
    forwardable
    pathname
    tempfile
    fiddle/import
    win32api
  ].freeze

  # def consolidate file, parser, files, no_stdlib: false
  #   @files = files
  #   @no_stdlib = no_stdlib
  # end

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
      # `require_relative` calls in `#{file}`.
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

    warn "`#{req_type}` found"

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
      remove(node.location.expression)
      return
    end

    warn "=> #{lib}"
    # req_path.visited = true
    # req_file = req_path.path

    # consolidator = RequireResolver.new
    # req_contents = consolidator.consolidate(req_file, @parser, @files, :no_stdlib => @no_stdlib)

    # TODO: what order does Ruby use here?
    file = (@root + lib).dirname.glob("*.{rb,so}").first
    replacement = File.read(file)
    banner = "#" + "-"*60 + "\n# #{file}\n#" + "-" * 60 + "\n"
    replacement = banner + replacement + "-" * 60 + "\n"

    replace node.location.expression, "\n#{replacement}\n"
  end

  def stdlib? lib
    STD_LIBS.include? lib
  end
end

if $0 == __FILE__
  abort "input file not provided" unless f = ARGV.first
  RequireResolver.new(f)
end
