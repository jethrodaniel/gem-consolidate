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
 cat <(./gem-consolidate.rb msh) <(echo Msh.start) > msh.rb && ruby msh.rb -V
```

## limitations

Only literal `require`s or `require_relative`s followed by a string will be processed.
