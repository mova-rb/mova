require "test_helper"
require "mova/storage/chain"

module Mova
  class ChainTest < Minitest::Test
    def storage1
      @storage1 ||= double("Storage 1")
    end

    def storage2
      @storage2 ||= double("Storage 2")
    end

    def chain
      @chain ||= Storage::Chain.new(storage1, storage2)
    end

    def test_read_from_storage1
      expect(storage1).to receive(:read).with(:hello).and_return("hello")
      assert_equal "hello", chain.read(:hello)
    end

    def test_read_from_storage2
      expect(storage1).to receive(:read).with(:hello).ordered.and_return(nil)
      expect(storage2).to receive(:read).with(:hello).ordered.and_return("hi")
      assert_equal "hi", chain.read(:hello)
    end

    def test_read_from_storage2_when_empty_string_is_returned_from_storage2
      expect(storage1).to receive(:read).with(:hello).ordered.and_return("")
      expect(storage2).to receive(:read).with(:hello).ordered.and_return("hi")
      assert_equal "hi", chain.read(:hello)
    end

    def test_read_multi_from_storage1_only
      expected = {"hello" => "world", "foo" => "bar"}
      expect(storage1).to receive(:read_multi).with("hello", "foo").and_return(expected)
      assert_equal expected, chain.read_multi("hello", "foo")
    end

    def test_read_multi_from_storage2_only
      expected = {"hello" => "world", "foo" => "bar"}
      expect(storage1).to receive(:read_multi).with("hello", "foo").and_return({})
      expect(storage2).to receive(:read_multi).with("hello", "foo").and_return(expected)
      assert_equal expected, chain.read_multi("hello", "foo")
    end

    def test_read_multi_from_storage1_and_storage2_with_preserved_key_order
      expected = {"hello" => "world", "foo" => "bar"}
      expect(storage1).to receive(:read_multi).with("hello", "foo").and_return("hello" => "world")
      expect(storage2).to receive(:read_multi).with("hello", "foo").and_return("foo" => "bar")
      result = chain.read_multi("hello", "foo")
      assert_equal expected, result
      assert_equal expected.keys, result.keys
    end

    def test_read_multi_from_second_storage_has_priority_for_non_empty_values
      expected = {"hello" => "world"}
      expect(storage1).to receive(:read_multi).with("hello").and_return("hello" => "")
      expect(storage2).to receive(:read_multi).with("hello").and_return("hello" => "world")
      assert_equal expected, chain.read_multi("hello")
    end

    def test_read_multi_doesnt_return_nils
      expected = {"hello" => "world"}
      expect(storage1).to receive(:read_multi).with("hello", "foo").and_return("hello" => "world")
      expect(storage2).to receive(:read_multi).with("hello", "foo").and_return({})
      assert_equal expected, chain.read_multi("hello", "foo")
    end

    def test_write
      expect(storage1).to receive(:write).with("hello", "world")
      expect(storage2).to receive(:write).with("hello", "world")
      chain.write("hello", "world")
    end

    def test_clear
      expect(storage1).to receive(:clear)
      expect(storage2).to receive(:clear)
      chain.clear
    end

    def test_exist_for_non_existing_value
      expect(storage1).to receive(:exist?).with("hello").and_return(false)
      expect(storage2).to receive(:exist?).with("hello").and_return(false)
      refute chain.exist?("hello")
    end

    def test_exist_in_first_storage
      expect(storage1).to receive(:exist?).with("hello").and_return(true)
      assert chain.exist?("hello")
    end

    def test_exist_in_second_storage
      expect(storage1).to receive(:exist?).with("hello").and_return(false)
      expect(storage2).to receive(:exist?).with("hello").and_return(true)
      assert chain.exist?("hello")
    end
  end
end
