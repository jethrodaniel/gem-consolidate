require_relative "init"

context Fib do
  test "VERSION" do
    refute(Fib::VERSION.nil?)
  end

  context "#fibonacci" do
    context "computes the nth fibonacci number" do
      test "small numbers" do
        assert(Fib.fibonacci(0) == 0)
        assert(Fib.fibonacci(1) == 1)
        assert(Fib.fibonacci(2) == 1)
        assert(Fib.fibonacci(3) == 2)
        assert(Fib.fibonacci(4) == 3)
        assert(Fib.fibonacci(5) == 5)
        assert(Fib.fibonacci(6) == 8)
      end

      test "largish (overflows long long int)" do
        assert(Fib.fibonacci(94) == 19_740_274_219_868_223_167)
      end
    end
    test "errors on negative numbers" do
      assert_raises Fib::Error do
        Fib.fibonacci(-1)
      end
    end
  end
end
