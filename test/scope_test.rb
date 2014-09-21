require "test_helper"

module Mova
  class ScopeTest < Minitest::Test
    def test_join
      assert_equal "hello.world", Scope.join("hello", "world")
    end

    def test_join_symbols
      assert_equal "hello.world", Scope.join(:hello, :world)
    end

    def test_join_array
      assert_equal "hello.world", Scope.join(["hello", "world"])
    end

    def test_split
      assert_equal ["hello", "world"], Scope.split("hello.world")
    end

    def test_flatten_simple
      expected = {"hello" => "world"}
      assert_equal expected, Scope.flatten(hello: "world")
    end

    def test_flatten_with_one_root
      expected = {"en.foo" => "bar", "en.inner.foo" => "bar"}
      assert_equal expected, Scope.flatten(en: {foo: "bar", inner: {foo: "bar"}})
    end

    def test_flatten_with_multiple_roots
      expected = {"en.foo" => "bar", "ru.foo" => "bar"}
      assert_equal expected, Scope.flatten(en: {foo: "bar"}, ru: {foo: "bar"})
    end

    def test_cross_join
      expected = ["de.hello", "de.hi", "en.hello", "en.hi"]
      assert_equal expected, Scope.cross_join([:de, :en], ["hello", "hi"])
    end
  end
end
