require "test_helper"
require "mova/storage/memory"

module Mova
  class MemoryTest < Minitest::Test
    def storage
      @storage ||= Storage::Memory.new
    end

    def test_read_for_non_existing_value
      assert_nil storage.read("hello")
    end

    def test_read
      storage.write("hello", "world")
      assert_equal "world", storage.read("hello")
    end

    def test_read_multi
      storage.write("hello", "world")
      storage.write("foo", "bar")
      expected = {"hello" => "world", "foo" => "bar"}
      assert_equal expected, storage.read_multi("hello", "foo")
    end

    def test_read_multi_doesnt_return_nils
      storage.write("hello", "world")
      expected = {"hello" => "world"}
      assert_equal expected, storage.read_multi("hello", "foo")
    end

    def test_exist_for_non_existing_value
      refute storage.exist?("hello")
    end

    def test_exist
      storage.write("hello", "world")
      assert storage.exist?("hello")
    end

    def test_exist_for_nil_value
      storage.write("hello", nil)
      assert storage.exist?("hello")
    end

    def test_clear
      storage.write("hello", "world")
      storage.clear
      assert_nil storage.read("hello")
    end
  end
end
