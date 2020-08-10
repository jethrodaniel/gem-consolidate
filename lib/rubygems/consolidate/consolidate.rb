# Simple tool to generate a single ruby file from a Ruby gem, by resolving
# `require`s, similar to combining c/c++ header files without duplication.
#
# Consolidate files into a single executable via
#
#     $ consolidate lib/msh.rb > exe

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

  def consolidate file, parser, files, no_stdlib: false
    @files = files
    @parser = parser.tap(&:reset)
    @no_stdlib = no_stdlib
    buffer = Parser::Source::Buffer.new("(#{file})")
    buffer.source = File.read(file)
    ast = @parser.parse(buffer)
    rewrite(buffer, ast)
  end

  def on_send node
    return unless node.children[1] == :require && node.children[2].type == :str

    handle_require(node)
  end

  private

  # $ ruby-parse -e "require 'ast'"
  # (send nil :require
  #   (str "ast"))
  #
  def handle_require node
    lib = node.children[2].children[0]

    if stdlib?(lib)
      warn "=> #{lib} (stdlib)"
      remove(node.location.expression) if @no_stdlib
      return
    end

    req_path = @files[lib]

    if req_path.visited?
      warn "=> #{lib} (already seen)"
      remove(node.location.expression)
      return
    end

    warn "=> #{lib}"
    req_path.visited = true
    req_file = req_path.path

    consolidator = RequireResolver.new
    req_contents = consolidator.consolidate(req_file, @parser, @files, :no_stdlib => @no_stdlib)

    replace node.location.expression, "\n#{req_contents}\n"
  end

  def stdlib? lib
    RequireResolver::STD_LIBS.include? lib
  end
end

RequirePath = Struct.new(:path, :visited) do
  def visited?
    visited
  end
end

class GemConsolidator
  def initialize gem_entry, header: nil, footer: nil, no_stdlib: false
    @gem_entry = gem_entry
    @name      = File.basename(@gem_entry).delete_suffix(".rb")
    @lib_dir   = Pathname.new(File.dirname(@gem_entry))
    @gem_root  = @lib_dir + ".."
    gemspec    = @gem_root + "#{@name}.gemspec"
    Dir.chdir(@gem_root) do
      @gem = Gem::Specification.load(gemspec.to_s)
    end

    @files = @gem.files.filter_map do |f|
      pre = @gem.require_paths.find { |p| f.start_with?(p) }

      if pre
        req = f.delete_prefix("#{pre}/").delete_suffix(".rb")
        path = Pathname.new(@gem_root) + f
        {req => RequirePath.new(path)}
      end
    end.reduce(:merge)

    @parser = Parser::CurrentRuby.new

    @footer = footer
    @header = header
    @no_stdlib = no_stdlib
  end

  def self.run gem_entry
    new(gem_entry).run
  end

  def run
    consolidator = RequireResolver.new
    single_file = consolidator.consolidate(@gem_entry, @parser, @files, :no_stdlib => @no_stdlib)
    [@header, single_file, @footer].join("\n").strip
  end
end
