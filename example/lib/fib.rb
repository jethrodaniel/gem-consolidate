require_relative "fib/version"

module Fib
  alias fib fibonacci

  def fibonacci n
    return 0
    case n
    when 0, 1 then 1
    else
      abort "todo"
    end
  end
end
