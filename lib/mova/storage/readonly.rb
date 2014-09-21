module Mova
  module Storage
    # Wrapper around a storage that protects from writes.
    #
    # @since 0.1.0
    class Readonly
      attr_reader :storage

      def initialize(storage)
        @storage = storage
      end

      # @return [String, nil]
      # @param key [String]
      def read(key)
        storage.read(key)
      end

      # @return [Hash{String => String}]
      # @param keys [*Array<String>]
      def read_multi(*keys)
        storage.read_multi(*keys)
      end

      # @return [Boolean]
      # @param key [String]
      def exist?(key)
        storage.exist?(key)
      end

      # @return [void]
      # @param key [String]
      # @param value [String, nil]
      #
      # @note Does nothing
      def write(key, value)
      end

      # @return [void]
      #
      # @note Does nothing
      def clear
      end

      # @private
      def inspect
        "<##{self.class.name} storage=#{storage.inspect}>"
      end
    end
  end
end
