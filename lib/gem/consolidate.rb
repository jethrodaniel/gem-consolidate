require_relative "consolidate/consolidator"
require_relative "consolidate/cli"

module Gem
  module Consolidate
    def self.start
      CLI.parse!
      Consolidator.new(ARGV.first).run
    end
  end
end
