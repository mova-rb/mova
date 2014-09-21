require "bundler/setup"
require "benchmark/ips"
require "active_support/notifications"
require "active_support/cache"
require "active_support/cache/strategy/local_cache"
require "active_support/cache/dalli_store"

require "mova"
require "mova/read_strategy/eager"

dalli = ActiveSupport::Cache::DalliStore.new("localhost:11211")
dalli.write("en.mova_test", "Mova test")

lazy = Mova::Translator.new(storage: dalli)
eager = Mova::Translator.new(storage: dalli).tap do |t|
  t.extend Mova::ReadStrategy::Eager
end

Benchmark.ips do |x|
  x.report("lazy") { lazy.get(:mova_test, [:uk, :ru, :en]) }
  x.report("eager") { eager.get(:mova_test, [:uk, :ru, :en]) }

  x.compare!
end
