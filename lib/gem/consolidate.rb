require_relative "consolidate/consolidator"
require_relative "consolidate/cli"

module Gem
  module Consolidate
    def self.start
      opts = CLI.parse! ARGV.first
      Consolidator.new(**opts).run
    end
  end
end
