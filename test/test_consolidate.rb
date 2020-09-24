require_relative "init"

context Gem::Consolidate do
  test "VERSION" do
    refute(Gem::Consolidate::VERSION.nil?)
  end

  test "snapshot matches" do
    snapshot = File.join(__dir__, "snapshot.rb")
    `bundle exec exe/consolidate example/lib/fib.rb 2>/dev/null > out`

    detail "snapshot does not match! Run rake:snapshot"
    detail "=== diff ===\n```\n#{`diff #{snapshot} out`}```\n"

    expected = File.read(snapshot).gsub("ruby  : 2.7.1", "ruby  : #{RUBY_VERSION}")

    assert expected == File.read("out")

    `rm out`
  end
end
