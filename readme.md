# gem-consolidate

![](https://github.com/jethrodaniel/gem-consolidate/workflows/ci/badge.svg)
![](https://img.shields.io/github/license/jethrodaniel/gem-consolidate.svg)
![](https://img.shields.io/github/stars/jethrodaniel/gem-consolidate?style=social)

Preprocess `require` like `#include`.

## install

```
git clone https://github.com/jethrodaniel/gem-consolidate
cd gem-consolidate
bundle && bundle exec rake
```

## usage

```
$ gem consolidate -h
Usage: gem consolidate {GEM,FILE} [options...] [options]

  Options:
        --footer=FOOTER              text to append at end of file
        --header=HEADER              text to append at beginning of file
        --no-stdlib                  remove stdlib `require`s (for MRuby)


  Common Options:
    -h, --help                       Get help on this command
    -V, --[no-]verbose               Set the verbose level of output
    -q, --quiet                      Silence command progress meter
        --silent                     Silence RubyGems output
        --config-file FILE           Use this config file instead of default
        --backtrace                  Show stack backtrace on errors
        --debug                      Turn on Ruby debugging
        --norc                       Avoid loading any .gemrc file


  Arguments:
    GEM, FILE   name of gem or path of the script to consolidate

  Summary:
    consolidate a Ruby script or gem, print to stdout

  Description:
    Consolidates a gem into a single file by replacing require statements
    with the file contents; prints to stdout.

    Note:

      - only `require_relative` supported
      # - gem entry **must** by <your_gem/lib/your_gem.rb>
      - only recognizes the literal `require`s, i.e, no `send(:require, "lib")`
```

For example

```
git clone https://github.com/jethrodaniel/msh && cd msh
bundle && bundle exec rake consolidate
./msh
```

## limitations

Only literal `require`s or `require_relative`s followed by a string will be processed.

## status

- [x] `require_relative`
- [ ] `require`
- [ ] ensure only top-level `require`s (i.e, can't require inside a method)
- [ ] panic on `autoload`
- [ ] process entire `gem`s, reading the `gemspec`, considering `require_paths`, etc.
- [ ] process entire input, use `TSort`
- [ ] test for circular dependencies

## contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jethrodaniel/gem-consolidate.

## license

MIT.
