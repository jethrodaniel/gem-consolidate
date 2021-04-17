require "rake"
require "gem-consolidate"

def sh *cmds
  Rake::FileUtilsExt.sh(*cmds)
end
