#!/usr/bin/env ruby

module Gem
  module Consolidate
    VERSION = '0.3.0'
  end
end

class Gem::Consolidate::Consolidator
  STD_LIBS = %w[
    csv
    English
    base64
    pp
    delegate
    tmpdir
    date
    rbconfig
    digest/md5
    digest/sha1
    digest/sha2
    e2mmap
    fiddle/import
    fileutils
    forwardable
    io/console
    jruby
    logger
    openssl
    ostruct
    optparse
    pathname
    readline
    reline
    ripper
    securerandom
    socket
    set
    stringio
    strscan
    tempfile
    timeout
    win32api
    shellwords
  ]

  USAGE = "#{$0} NAME"
  REQ_REGEX = /^(require|require_relative)\s+['"]([\w\.\/]+)["']\s*$/

  def initialize **opts
  end

  # Run `gem consolidate` command.
  #
  # ```
  # Gem::Consolidate.start!
  # ```
  #
  def run!
    name = ARGV.first
    abort "missing gem NAME" unless name

    begin
      gemspec = Gem::Specification.find_by_name(name)
    rescue Gem::MissingSpecError => e
      abort "can't load gem `#{name}`"
    end

    files = gem_files(gemspec)

    init = files.find { |f| f.end_with?(".rb") && File.basename(f, File.extname(f)) == name }
    unless init
      file_list = files.sort.map { |f| "  - #{f}\n" }.join
      abort "can't find entry file for gem `#{name}`.\nFiles: \n#{file_list}"
    end

    expand init, files, gemspec.full_require_paths
  end

  private

  # Print the gem's source code, resolving `require`s.
  #
  def expand file, files, req_paths, seen = []
    warn "-> #{file}"
    dir = File.dirname(file)
    File.foreach(file) do |line|
      reqs = line.scan(REQ_REGEX)
      puts line if reqs.empty?

      reqs.each do |req_type, req|
        case req_type
        when "require_relative"
          if req =~ /\.(rb|so)$/
            path = File.join(dir, req)
          else
            path = Dir.glob("#{File.join(dir, req)}.{rb,so}").first
          end
        when "require"
          if STD_LIBS.include?(req) || (ENV['IGNORED'] || '').split(',').include?(req)
            puts line
            next
          end
          path = req_paths.flat_map do |p|
            glob = "#{p}/**/*#{req}"
            glob += ".{rb,so}" unless req =~ /\.(rb|so)$/
            Dir.glob(glob)
          end.first
        end

        abort "can't find path for #{req_type} \"#{req}\"" unless path

        path = File.absolute_path(path)
        next if seen.include?(path)

        seen << path
        expand path, files, req_paths, seen
      end
    end
  end

  # Find gem files.
  #
  # Adapted from https://github.com/rubygems/rubygems/blob/96e5cff3df491c4d943186804c6d03b57fcb459b/lib/rubygems/commands/contents_command.rb
  #
  def gem_files(spec)
    spec.default_gem? ? files_in_default_gem(spec) : files_in_gem(spec)
  end
  def files_in_gem(spec)
    files = spec.full_require_paths.flat_map { |p| Dir.glob("#{p}/**/*.{rb,so}") }
  end
  def files_in_default_gem(spec)
    spec.files.flat_map do |file|
      File.join(RbConfig::CONFIG['rubylibdir'], file)
    end
  end
end
