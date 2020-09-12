require_relative "fib/version"
require_relative "fib/error"

module Fib
  def self.fibonacci n
    case n
    when -Float::INFINITY..-1
      raise Error, "fibonacci(n) is not defined for negative values of n"
    when 0, 1
      1
    else
      abort "todo"
    end
  end
end
