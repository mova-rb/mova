module Mova
  module Storage
    # Thin wrapper around Hash.
    #
    # @note This class was designed to be *not* thread-safe for the sake of
    #   speed. However, if you store translations in static YAML files and
    #   do not write to the storage during application runtime, this is not a
    #   big deal.
    #
    #   If you need thread-safe in-memory implemenation, use
    #   {http://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html ActiveSupport::Cache::MemoryStore}.
    #
    #   Also note that with any in-memory implementation you'll have a copy of all
    #   translations data in each spawned worker. Depending on number of your locales,
    #   translation keys and workers, it may take up a lot of memory. This is the fastest
    #   storage though.
    #
    # @since 0.1.0
    class Memory
      def initialize
        @storage = {}
      end

      # @return [String, nil]
      # @param key [String]
      def read(key)
        @storage[key]
      end

      # @return [Hash]
      # @param keys [*Array<String>]
      # @example
      #   storage.write("foo", "bar")
      #   storage.write("baz", "qux")
      #   storage.read_multi("foo", "baz") #=> {"foo" => "bar", "baz" => "qux"}
      def read_multi(*keys)
        keys.each_with_object({}) do |key, memo|
          result = read(key)
          memo[key] = result if result
        end
      end

      # @return [void]
      # @param key [String]
      # @param value [String, nil]
      def write(key, value)
        @storage[key] = value
      end

      # @return [Boolean]
      # @param key [String]
      def exist?(key)
        @storage.key?(key)
      end

      # @return [void]
      def clear
        @storage.clear
      end

      # @private
      def inspect
        "<##{self.class.name}>"
      end
    end
  end
end
