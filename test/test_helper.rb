require "bundler/setup"
require "mova"

require "minitest"
Minitest.autorun

require "rspec/mocks"

RSpec::Mocks.configuration.syntax = :expect

module RSpec::Mocks
  remove_const :MockExpectationError
  # treat as Minitest failure, not an exception
  MockExpectationError = Class.new(Minitest::Assertion)
end

module Mova
  module Test
    module Doubles
      def storage
        @storage ||= double("Storage")
      end
    end

    module RSpecMocksForMinitest
      include RSpec::Mocks::ExampleMethods

      def before_setup
        RSpec::Mocks.setup
        super
      end

      def after_teardown
        begin
          RSpec::Mocks.verify
        ensure
          RSpec::Mocks.teardown
        end
        super
      end
    end
  end
end

class Minitest::Test
  include Mova::Test::RSpecMocksForMinitest
end
