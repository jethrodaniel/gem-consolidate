require "English"

require_relative "fib/version"
require_relative "fib/error"
require_relative "fib/util/scanner"

module Fib
  def self.fibonacci n
    raise Error, "fibonacci(n) is not defined for negative values of n" if n.negative?

    flip = [0, 1]

    1.upto(n) { |i| flip[i%2] = flip.sum }

    flip[n%2]
  end
end

require_relative "fib/util"
