module Consolidate
  if RUBY_ENGINE == "ruby"
    STD_LIBS = %w[
      English
      e2mmap
      fiddle/import
      fileutils
      forwardable
      io/console
      jruby
      logger
      pathname
      readline
      reline
      ripper
      strscan
      tempfile
      timeout
      win32api
    ].freeze
  end
end
