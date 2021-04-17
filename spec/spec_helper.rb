require "rake"

def sh *cmds
  Rake::FileUtilsExt.sh(*cmds)
end
