require "minitest/autorun"

describe Gem::Consolidate do
  it "has a version" do
    _(Gem::Consolidate::VERSION).must_match /\d.\d.\d/
  end
end
