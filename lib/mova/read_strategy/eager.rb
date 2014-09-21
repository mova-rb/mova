module Mova
  module ReadStrategy
    # This strategy is more perfomant with a remote storage, where each
    # read results in a network roundtrip. Even if your cache or database
    # is located on localhost, reading from a socket is much more slower
    # than reading from memory.
    # Instead of making one read per locale/scope fallback, we get combination
    # of all fallbacks and make one request to the storage.
    #
    # @example Instantiating a translator with eager strategy
    #   dalli = ActiveSupport::Cache::DalliStore.new("localhost:11211")
    #   translator = Mova::Translator.new(storage: dalli)
    #   translator.extend Mova::ReadStrategy::Eager
    #
    # @since 0.1.0
    module Eager
      def read_first(locales, key_with_scopes)
        locales_with_scopes = Scope.cross_join(locales, key_with_scopes)
        results = storage.read_multi(*locales_with_scopes)
        _, value = results.find { |_, value| Mova.presence(value) }
        value
      end
    end
  end
end
