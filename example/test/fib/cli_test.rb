require_relative "../init"
require_relative "../helper"

context "fib" do
  _test "-h, --help" do
    output = sh("fib -h")
    asserted = <<~MSG
      Usage:
          fib n # prints the nth fibonacci number

      Options:
          -V, --version  show the version
          -h, --help     print this help
    MSG
    assert(output == asserted)
  end

  _test "-V, --version" do
    msg = "fib version #{Fib::VERSION}\n"
    assert(sh("fib -V") == msg)
    assert(sh("fib --version") == msg)
  end
end
