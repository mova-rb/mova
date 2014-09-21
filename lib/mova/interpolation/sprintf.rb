module Mova
  module Interpolation
    # Wrapper around {http://ruby-doc.org/core/Kernel.html#method-i-sprintf Kernel#sprintf} with
    # fallback for missing placeholders.
    #
    # @since 0.1.0
    class Sprintf
      PLACEHOLDER_RE = Regexp.union(
        /%%/,         # escape character
        /%\{(\w+)\}/, # %{hello}
        /%<(\w+)>(.*?\d*\.?\d*[bBdiouxXeEfgGcps])/ # %<hello>.d
      )
      ESCAPE_SEQUENCE = "%%".freeze
      ESCAPE_SEQUENCE_REPLACEMENT = "%".freeze

      # Replaces each placeholder like "%{{hello}}" or "%<hello>3.0f" with given values.
      # @return [String]
      # @param string [String]
      # @param values [Hash{Symbol => String}]
      #
      # @example
      #   interpolator.call("Hello, %{you}!", you: "world") #=> "Hello, world!"
      # @example Sprintf-like formatting
      #   # this is the equivalent to `sprintf("%3.0f", 1.0)`
      #   interpolator.call("%<num>3.0f", num: 1.0) #=> "  1"
      #
      # @note Unlike `Kernel#sprintf` it won't raise an exception in case of missing
      #   placeholder. Instead {#missing_placeholder} will be used to return a default
      #   replacement.
      #     sprintf("Hello %{world}", other: "value")  #=>  KeyError: key{world} not found
      #     interpolator.call("Hello %{world}", other: "value") #=> "Hello %{world}"
      #
      # @see http://ruby-doc.org/core/Kernel.html#method-i-sprintf
      def call(string, values)
        string.to_str.gsub(PLACEHOLDER_RE) do |match|
          if match == ESCAPE_SEQUENCE
            ESCAPE_SEQUENCE_REPLACEMENT
          else
            placeholder = ($1 || $2).to_sym
            replacement = values[placeholder] || missing_placeholder(placeholder, values, string)
            $3 ? sprintf("%#{$3}", replacement) : replacement
          end
        end
      end

      module Overridable
        # @return [String] default replacement for missing placeholder
        # @param placeholder [Symbol]
        # @param values [Hash{Symbol => String}] all given values for interpolation
        #
        # @example Wrap missing placeholders in HTML tag
        #   interpolator = Mova::Interpolation::Sprintf.new.tap do |i|
        #     def i.missing_placeholder(placeholder, values)
        #       "<span class='error'>#{placeholder}<span>"
        #     end
        #   end
        #   interpolator.call("%{my} %{notes}", my: "your") #=> "your <span class='error'>notes</span>"
        #
        # @example Raise an exception in case of missing placeholder
        #   interpolator = Mova::Interpolation::Sprintf.new.tap do |i|
        #     def i.missing_placeholder(placeholder, values)
        #       raise KeyError.new("#{placeholder.inspect} is missing, #{values.inspect} given")
        #     end
        #   end
        #   interpolator.call("%{my} %{notes}", my: "your") #=> KeyError: :notes is missing, {my: "your"} given
        def missing_placeholder(placeholder, values)
          "%{#{placeholder}}"
        end
      end
      include Overridable
    end
  end
end
