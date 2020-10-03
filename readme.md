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
