module Mova
  module ReadStrategy
    # This strategy is more perfomant with an in-memory storage, where
    # read is cheap compared to a remote storage.
    # It is included in {Translator} by default.
    #
    # @since 0.1.0
    module Lazy
      def read_first(locales, key_with_scopes)
        locales.each do |locale|
          key_with_scopes.each do |key|
            result = storage.read(Scope.join(locale, key))
            return result if Mova.presence(result)
          end
        end

        nil
      end
    end
  end
end
