require_relative "consolidate/consolidator"

module Gem
  module Consolidate
    def self.start
      abort "input file not provided" unless f = ARGV.first
      Consolidate::Consolidator.new(f).run
    end
  end
end