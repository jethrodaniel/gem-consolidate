require_relative "consolidate/consolidator"
require_relative "consolidate/cli"

module Gem
  module Consolidate
    def self.start
      opts = CLI.parse!
      Consolidator.new(ARGV.first, **opts).run
    end
  end
end
