require "bundler/setup"
require "benchmark/ips"

require "mova"
require "mova/storage/memory"
require "mova/read_strategy/eager"

memory = Mova::Storage::Memory.new
memory.write("en.mova_test", "Mova test")

lazy = Mova::Translator.new(storage: memory)
eager = Mova::Translator.new(storage: memory).tap do |t|
  t.extend Mova::ReadStrategy::Eager
end

Benchmark.ips do |x|
  x.report("lazy") { lazy.get(:mova_test, [:uk, :ru, :en]) }
  x.report("eager") { eager.get(:mova_test, [:uk, :ru, :en]) }

  x.compare!
end
