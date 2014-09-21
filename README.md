# Mova

**Mova** is a translation and localization library that aims to be simple and fast.

## Name origin

"Мова" [['mɔwɑ][mova-pronounce]] in Ukrainian and Belarusian means "language".

## Why

Because [I18n][i18n] code is hard to reason about.

## Status

Not tested in production. Localization part is yet to be implemented.

## Installation

Add this line to your application's Gemfile and run `bundle`:

```ruby
gem 'mova'
```

## Usage

```ruby
require "mova"

# instantiate a translator with in-memory storage
translator = Mova::Translator.new

# store translations
translator.put(en: {hello: "world!"})

# retreive translations
translator.get("hello", :en) #=> "world!"

# wrap existing storage
require "redis-activesupport"
redis = ActiveSupport::Cache::RedisStore.new("localhost:6379/0")
translator = Mova::Translator.new(storage: redis)
translator.get(:hi_from_redis, :en) #=> "Hi!"
```

## Documentation

*link to rubydoc*

## Design principles

1.  **Translation and localization data should be decoupled.**

    Localization info describes how dates, numbers, currencies etc. should be rendered,
and what pluralization rules and writing direction should be used. This data is rarely if ever
changed during project lifetime.

    On the other hand translation data is always subject to change, because you may need to
adjust text length to fit it into new design, update your product title to be more SEO friendly
and so on.

    It is more performant to keep localization data in a static Ruby class, rather then
fetch it from a translation storage each time when we want to localize a date. This still
allows to modify locales on per project level.

    Ruby class is also a natural place for methods and collection data types, while procs and hashes
being put into a translation storage feels awkward.

2.  **Translations should be kept in a simple key-value storage.**

    Simple storage means that given a string key it should return only a string or
nil if nothing found. No object serialization. No hashes as a return value.

    Such limitation allows to use almost anything as a storage: Ruby hash, file storage that maps
to a hash, any RDMBS, any key-value store, or any combination of them.

    This also forces decoupling of translation retrieval and translation management (finding
untranslated strings, providing hints to translators etc.) since not much data can be put in a key.

3.  **Translation framework should not be aware of any file format.**

    If we need to import translations from a file, hash should be used as input format. No matter
which file format is used to store data on a disk, whether it be YAML or JSON, or TOML, any option
should work transparently.

4.  **Exception should be used as a last resort when controlling flow.**

    Raising and catching an exception in Ruby is a very expensive operation and should be avoided
whenever possible.

5.  **Instance is better than singleton.**

    You can have separate versions of translator for models and templates. You can have different
storages. You can use different interpolation rules.

## Related projects

* [mova-i18n][mova-i18n] - integrating with/replacing I18n.

[mova-pronounce]: http://upload.wikimedia.org/wikipedia/commons/f/ff/Uk-%D0%BC%D0%BE%D0%B2%D0%B0.ogg
[mova-i18n]: https://github.com/mova-rb/mova-i18n
[i18n]: https://github.com/svenfuchs/i18n
