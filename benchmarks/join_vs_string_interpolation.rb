require "bundler/setup"
require "benchmark/ips"

SEPARATOR = ".".freeze

def array_join(*keys)
  keys.join(SEPARATOR)
end

def string_join(first, second = nil)
  if second
    "#{first}#{SEPARATOR}#{second}"
  else
    first.join(SEPARATOR)
  end
end

Benchmark.ips do |x|
  x.report("join") { array_join("hello", "world") }
  x.report("string") { string_join("hello", "world") }

  x.compare!
end
