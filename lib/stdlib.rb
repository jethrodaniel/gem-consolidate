module Consolidate
  if RUBY_ENGINE == "ruby"
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
  end
end
