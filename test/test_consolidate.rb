require_relative "init"

context Consolidate do
  test "VERSION" do
    refute(Consolidate::VERSION.nil?)
  end

  test "snapshot matches" do
    snapshot = File.read(File.join(__dir__, 'snapshot.rb'))
    current = `bundle exec bin/consolidate example/lib/fib.rb 2>/dev/null`

    detail "snapshot does not match! Run rake:snapshot"
    detail "=== snapshot ===\n```\n#{snapshot}```\n"
    detail "=== current ===\n```\n#{current}```\n"

    assert snapshot == current
  end
end
