require "mova/scope"
require "mova/read_strategy/lazy"
require "mova/translator"

module Mova
  EMPTY_TRANSLATION = "".freeze

  # @return [String] if translation is non-empty string
  # @return [nil] if translation is nil or an empty string
  #
  # @example
  #   Mova.presence("hello") #=> "hello"
  #   Mova.presence(nil) #=> nil
  #   Mova.presence("") #=> nil
  #
  # @note Unlike ActiveSupport's Object#presence this method doesn't
  #   treat a string made of spaces as blank
  #     "  ".presence #=> nil
  #     Mova.presence("  ") #=> "  "
  #
  # @since 0.1.0
  def self.presence(translation)
    return nil if translation == EMPTY_TRANSLATION
    translation
  end

  # Classes under this namespace must conform with
  # {http://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html ActiveSupport::Cache::Store} API.
  #
  # Instances must respond to at least #read, #read_multi, #write, #exist?, #clear. It is allowed #clear
  # to be implemented as no-op.
  module Storage; end

  # Classes under this namespace must implement #call(String, Hash) and #missing_placeholder(Symbol, Hash).
  module Interpolation; end
end
