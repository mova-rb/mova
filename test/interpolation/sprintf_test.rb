require "test_helper"
require "mova/interpolation/sprintf"

module Mova
  class SprintfTest < Minitest::Test
    def interpolator
      @interpolator ||= Interpolation::Sprintf.new
    end

    def test_no_placeholders_and_no_values
      assert_equal "hi there!", interpolator.call("hi there!", {})
    end

    def test_no_placeholders_and_values
      assert_equal "hi there!", interpolator.call("hi there!", subject: "people")
    end

    def test_replaced_placeholders
      values = {subject: "people", type: "smart"}
      assert_equal "hi there, smart people!", interpolator.call("hi there, %{type} %{subject}!", values)
    end

    def test_placeholder_and_extra_value
      assert_equal "hi there, people!", interpolator.call("hi there, %{subject}!", subject: "people", type: "smart")
    end

    def test_placeholder_and_missing_value
      values = {type: "smart"}
      expect(interpolator).to receive(:missing_placeholder).with(:subject, values, "hi there, %{subject}!").and_return("<missing value>")
      assert_equal "hi there, <missing value>!", interpolator.call("hi there, %{subject}!", values)
    end

    def test_escaped_placeholder
      assert_equal "hi there, %{subject}!", interpolator.call("hi there, %%{subject}!", subject: "people")
    end

    def test_activesupport_safebuffer_like_strings
      substring_class = Class.new(String) do
        def gsub(*args, &blk)
          to_str.gsub(*args, &blk)
        end
      end

      string = substring_class.new("hi there, %{subject}!")
      assert_equal "hi there, people!", interpolator.call(string, subject: "people")
    end

    def test_ruby_sprintf
      assert_equal "1", interpolator.call("%<num>d", num: 1)
      assert_equal "0b1", interpolator.call("%<num>#b", num: 1)
      assert_equal "foo", interpolator.call("%<msg>s", msg: "foo")
      assert_equal "1.000000", interpolator.call("%<num>f", num: 1.0)
      assert_equal "  1", interpolator.call("%<num>3.0f", num: 1.0)
      assert_equal "100.00", interpolator.call("%<num>2.2f", num: 100.0)
      assert_equal "0x64", interpolator.call("%<num>#x", num: 100.0)
      assert_raises(ArgumentError) { interpolator.call("%<num>,d", num: 100) }
      assert_raises(ArgumentError) { interpolator.call("%<num>/d", num: 100) }
    end
  end
end
