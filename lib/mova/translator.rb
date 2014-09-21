module Mova
  # Wrapper around a storage that provides key management and fallbacks.
  #
  # Translator knows that keys by definition are dot-separated and each key should
  # include a locale. It also flattens any given hash, because ordinary key-value
  # storage can handle only flat data.
  #
  # Translator is in charge of returning non-empty data for given set of locales and keys,
  # because it is likely that some translations are missing.
  #
  # @since 0.1.0
  class Translator
    include ReadStrategy::Lazy

    # @!attribute [r] storage
    # Key-value storage for translations.
    # @return [#read, #read_multi, #write, #exist?, #clear]
    attr_reader :storage

    module Overridable
      # @param opts [Hash]
      # @option opts [see #storage] :storage default: {Storage::Memory} instance
      def initialize(opts = {})
        @storage = opts.fetch(:storage) do
          require "mova/storage/memory"
          Storage::Memory.new
        end
      end

      # @return [Array<String, Symbol>] locales that should be tried until non-empty
      #   translation would be found.
      # @param current_locale [String, Symbol]
      #
      # @example Override locale fallbacks
      #   translator = Mova::Translator.new.tap do |t|
      #     def t.locales_to_try(locale)
      #       [locale, :en]
      #     end
      #   end
      #   translator.put(en: {hello: "world"})
      #   translator.get(:hello, :de) #=> "world"; tried "de.hello", then "en.hello"
      def locales_to_try(current_locale)
        [current_locale]
      end

      # @return [Array<String, Symbol>] keys that should be tried until non-empty
      #   translation would be found.
      # @param key [String, Symbol]
      #
      # @example Override key fallbacks
      #   translator = Mova::Translator.new.tap do |t|
      #     def t.keys_to_try(key)
      #       [key, "errors.#{key}"]
      #     end
      #   end
      #   translator.put(en: {errors: {fail: "Fail"}})
      #   translator.get(:fail, :en) #=> "Fail"; tried "en.fail", then "en.errors.fail"
      def keys_to_try(key)
        [key]
      end

      # @return [String] default value if no translation was found.
      # @param locales [Array<String>] that were used to find a translation.
      # @param keys [Array<String>] that were used to find a translation.
      # @param get_options [Hash{Symbol => Object}] that were passed to {#get}
      #
      # @example Override default value handling
      #   translator = Mova::Translator.new.tap do |t|
      #     def t.default(locales, keys, get_options)
      #       "translation is missing"
      #     end
      #   end
      #   translator.get("hello", :de) #=> "translation is missing"
      def default(locales, keys, get_options)
        EMPTY_TRANSLATION
      end
    end
    include Overridable

    # Retrieves translation from the storage or return default value.
    #
    # @return [String] translation or default value if nothing found
    #
    # @example
    #   translator.put(en: {hello: "world"})
    #   translator.get("hello", :en) #=> "world"
    #   translator.get("bye", :en) #=> ""
    #
    # @example Providing the default if nothing found
    #   translator.get("hello", :de, default: "nothing") #=> "nothing"
    #
    # @overload get(key, locale, opts = {})
    #   @param key [String, Symbol]
    #   @param locale [String, Symbol]
    #
    # @overload get(keys, locale, opts = {})
    #   @param keys [Array<String, Symbol>] use this to redefine an array returned
    #     by {#keys_to_try}.
    #   @param locale [String, Symbol]
    #
    #   @example
    #     translator.put(en: {fail: "Fail"})
    #     translator.get(["big.fail", "mine.fail"], :en) #=> ""; tried "en.big.fail", then "en.mine.fail"
    #
    # @overload get(key, locales, opts = {})
    #   @param key [String, Symbol]
    #   @param locales [Array<String, Symbol>] use this to redefine an array returned
    #     by {#locales_to_try}.
    #
    #   @example
    #     translator.put(en: {hello: "world"})
    #     translator.get(:hello, :de) #=> ""; tried only "de.hello"
    #     translator.get(:hello, [:de, :en]) #=> "world"; tried "de.hello", then "en.hello"
    #
    #   @example Disable locale fallbacks locally
    #     translator.put(en: {hello: "world"}) # suppose this instance has fallback to :en locale
    #     translator.get(:hello, :de) #=> "world"; tried "de.hello", then "en.hello"
    #     translator.get(:hello, [:de]) #=> ""; tried only "de.hello"
    #
    # @overload get(keys, locales, opts = {})
    #   @param keys [Array<String, Symbol>]
    #   @param locales [Array<String, Symbol>]
    #
    #   @note Keys fallback has a higher priority than locales one, that is, Mova
    #     tries to find a translation for any given key and only then it fallbacks
    #     to another locale.
    #
    # @param opts [Hash]
    # @option opts [String] :default use this to redefine default value returned
    #   by {#default}.
    #
    # @see #locales_to_try
    # @see #keys_to_try
    # @see #default
    #
    def get(key, locale, opts = {})
      keys = resolve_scopes(key)
      locales = resolve_locales(locale)
      read_first(locales, keys) || opts[:default] || default(locales, keys, opts)
    end

    # Writes translations to the storage.
    #
    # @return [void]
    # @param translations [Hash{String, Symbol => String, Hash}] where
    #   root key/keys must be a locale
    #
    # @example
    #   translator.put(en: {world: "world"}, uk: {world: "світ"})
    #   translator.get("world", :uk) #=> "світ"
    def put(translations)
      Scope.flatten(translations).each do |key, value|
        storage.write(key, value) unless storage.exist?(key)
      end
    end

    # @see #put
    #
    # @return [void]
    #
    # @note This method overwrites existing translations.
    def put!(translations)
      Scope.flatten(translations).each do |key, value|
        storage.write(key, value)
      end
    end

    # @private
    def inspect
      "<##{self.class.name} storage=#{storage.inspect}>"
    end

    private

    def resolve_locales(locale)
      (locale if locale.is_a? Array) || locales_to_try(locale)
    end

    def resolve_scopes(key)
      (key if key.is_a? Array) || keys_to_try(key)
    end
  end
end
