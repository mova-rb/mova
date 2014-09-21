require "bundler/setup"
require "benchmark/ips"

storage1 = Object.new.tap do |s|
  def s.get
    nil
  end
end

storage2 = Object.new.tap do |s|
  def s.get
    "result"
  end
end

class Chain
  attr_reader :storages

  def initialize(*storages)
    @storages = storages
  end

  def with_each
    storages.each do |s|
      result = s.get
      return result if result
    end
  end

  def with_or
    storages[0].get || storages[1].get
  end
end

chain = Chain.new(storage1, storage2)

Benchmark.ips do |x|
  x.report("each") { chain.with_each }
  x.report("or") { chain.with_or }

  x.compare!
end
