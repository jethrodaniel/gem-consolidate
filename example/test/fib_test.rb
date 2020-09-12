require_relative "init"

context Fib do
  test "VERSION" do
    refute(Fib::VERSION.nil?)
  end

  context "#fibonacci" do
    test "computes the nth fibonacci number" do
      assert(Fib.fibonacci(0) == 1)
    end
    test "errors on negative numbers" do
      assert_raises Fib::Error do
        Fib.fibonacci(-1)
      end
    end
  end
end
