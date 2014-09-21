require "test_helper"
require "mova/storage/readonly"

module Mova
  class ReadonlyTest < Minitest::Test
    include Test::Doubles

    def readonly
      @readonly ||= Storage::Readonly.new(storage)
    end

    def test_read
      expect(storage).to receive(:read).with("hello").and_return("world")
      assert_equal "world", readonly.read("hello")
    end

    def test_read_multi
      expected = {"hello" => "world"}
      expect(storage).to receive(:read_multi).with("hello").and_return(expected)
      assert_equal expected, readonly.read_multi("hello")
    end

    def test_write
      assert_nil readonly.write("hello", "world")
    end

    def test_exist
      expect(storage).to receive(:exist?).with("hello").and_return(true)
      assert readonly.exist?("hello")
    end

    def test_clear
      assert_nil readonly.clear
    end
  end
end
