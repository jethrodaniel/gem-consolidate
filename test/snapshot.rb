#------------------------------------------------------------
# Automatically consolidated from `require` and
# `require_relative` calls.
#
# ruby  : 2.7.1
# parser: 2.7.1.4
#
# entry point: `example/lib/fib.rb`
#------------------------------------------------------------
# require "English" # stdlib excluded

# require_relative "fib/version"

#------------------------------------------------------------
# example/lib/fib/version.rb
#------------------------------------------------------------
module Fib
  VERSION = "0.0.0"
end
#------------------------------------------------------------

# require_relative "fib/error"

#------------------------------------------------------------
# example/lib/fib/error.rb
#------------------------------------------------------------
# require_relative "util/scanner"

##-----------------------------------------------------------
# example/lib/fib/util/scanner.rb
##-----------------------------------------------------------
# require "strscan" # stdlib excluded

module Fib
  class Scanner
  end
end
##-----------------------------------------------------------

# require_relative "etc/wow"

##-----------------------------------------------------------
# example/lib/fib/etc/wow.rb
##-----------------------------------------------------------
module Fib
  WOW = "- Owen Wilson".freeze
end
##-----------------------------------------------------------


module Fib
  class Error < StandardError
  end
end
#------------------------------------------------------------

# require_relative "fib/util/scanner"

#------------------------------------------------------------
# example/lib/fib/util/scanner.rb
#------------------------------------------------------------
# require "strscan" # stdlib excluded

module Fib
  class Scanner
  end
end
#------------------------------------------------------------


module Fib
  def self.fibonacci n
    raise Error, "fibonacci(n) is not defined for negative values of n" if n.negative?

    flip = [0, 1]

    1.upto(n) { |i| flip[i%2] = flip.sum }

    flip[n%2]
  end
end

# require_relative "fib/util"

#------------------------------------------------------------
# example/lib/fib/util.rb
#------------------------------------------------------------
# require_relative "util/over/9_000"

##-----------------------------------------------------------
# example/lib/fib/util/over/9_000.rb
##-----------------------------------------------------------
module Fib
  module Utils
    module Over
      class NineThousand
        MSG = "It's over nine thousand!"
      end
    end
  end
end
##-----------------------------------------------------------


module Fib
  module Utils
    A = Over::NineThousand::MSG
  end
end
#------------------------------------------------------------
