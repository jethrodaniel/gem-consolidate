require "spec_helper"
require "minitest/autorun"

def snap path
  sh "bundle exec exe/consolidate lib/gem/consolidate.rb " \
     "--exclude parser/current " \
     "--footer='Gem::Consolidate.start' " \
     "> #{path}"
end

describe Gem::Consolidate do
  it "has a version" do
    _(Gem::Consolidate::VERSION).must_match /\d.\d.\d/
  end

  it "matches the snapshot" do
    snapshot = File.open "spec/snapshot.rb", "r"
    temp     = Tempfile.new 'test.rb'
    snap temp.path

    unless temp.read == snapshot.read
      cmd = "diff #{snapshot.path} #{temp.path}"
      assert temp.read == snapshot.read, "snapshot doesn't match.\n#{cmd}n#{`#{cmd}`}"
    end
  end
end
