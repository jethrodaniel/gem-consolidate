#------------------------------------------------------------
# Automatically consolidated from `require` and
# `require_relative` calls.
#
# ruby  : 2.7.1
# parser: 2.7.1.4
#
# entry point: `example/lib/fib.rb`
#------------------------------------------------------------
require "English"

# require_relative "fib/version"

#=== start: example/lib/fib/version.rb
module Fib
  VERSION = "0.0.0".freeze
end
#=== end: example/lib/fib/version.rb

# require_relative "fib/error"

#=== start: example/lib/fib/error.rb
# require_relative "util/scanner"

##=== start: example/lib/fib/util/scanner.rb
require "strscan"

module Fib
  class Scanner
  end
  S = Scanner
end
##=== end: example/lib/fib/util/scanner.rb

# require_relative "etc/wow"

##=== start: example/lib/fib/etc/wow.rb
module Fib
  WOW = "- Owen Wilson".freeze
  W = WOW
end
##=== end: example/lib/fib/etc/wow.rb


module Fib
  class Error < StandardError
  end
  E = Error
end
#=== end: example/lib/fib/error.rb

# require_relative "fib/util/scanner" # resolved previously

module Fib
  def self.fibonacci n
    raise Error, "fibonacci(n) is not defined for negative values of n" if n.negative?

    flip = [0, 1]

    1.upto(n) { |i| flip[i % 2] = flip.sum }

    flip[n % 2]
  end
end

# require_relative "fib/util"

#=== start: example/lib/fib/util.rb
# require_relative "util/over/9_000"

##=== start: example/lib/fib/util/over/9_000.rb
module Fib
  module Utils
    module Over
      class NineThousand
        MSG = "It's over nine thousand!".freeze
      end
    end
  end
end
##=== end: example/lib/fib/util/over/9_000.rb

# require_relative "util/parser"

##=== start: example/lib/fib/util/parser.rb
# require_relative "scanner" # resolved previously

module Fib
  class Parser
  end
  P = Parser
end
##=== end: example/lib/fib/util/parser.rb


module Fib
  module Utils
    A = Over::NineThousand::MSG
  end
  U = Utils
end
#=== end: example/lib/fib/util.rb

