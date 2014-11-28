module Mova
  # Translation keys are usually organized in a tree, where each nesting level
  # corresponds to a specific part of your application. Such hierarchical organization
  # allows to reuse the keys and keep their names relatively short.
  #
  # Full path to a key forms a scope. Think of a scope as a namespace.
  #
  #   # here we have an example YAML file with "blank" keys within different scopes
  #   activemodel:
  #     errors:
  #       blank: Can't be blank
  #       message:
  #         blank: Please provide a message
  #
  # Since Mova is designed to work with any key-value storage, we need to store a key
  # with its own full scope and a locale. We use dot-separated strings as it's a common
  # format in Ruby community.
  #
  #   "en.activemodel.errors.blank"
  #   "en.activemodel.errors.message.blank"
  #
  # @note In YAML (and other storages that map to a hash) you can't store a value
  #   for a nesting level itself.
  #     errors: !can't have translation here
  #       blank: Please enter a value
  #   Other key-value storages usually don't have such limitation, however, it's better
  #   to not introduce incompatibles in this area.
  #
  # @since 0.1.0
  module Scope
    extend self

    SEPARATOR = ".".freeze

    # Makes a new scope from given parts.
    #
    # @return [String]
    #
    # @overload join(part1, part2)
    #   @param part1 [String, Symbol]
    #   @param part2 [String, Symbol]
    #
    # @overload join(parts)
    #   @param parts [Array<String, Symbol>]
    #
    # @example
    #   Scope.join("hello", "world") #=> "hello.world"
    #   Scope.join([:hello, "world"]) #=> "hello.world"
    def join(part_or_array, second_part = nil)
      if second_part
        "#{part_or_array}#{SEPARATOR}#{second_part}"
      else
        # then assume it's an array
        part_or_array.join(SEPARATOR)
      end
    end

    # Split a scope into parts.
    #
    # @return [Array<String>]
    # @param scope [String]
    #
    # @example
    #   Scope.split("hello.world") #=> ["hello", "world"]
    def split(scope)
      scope.split(SEPARATOR)
    end

    # Recurrently flattens hash by converting its keys to fully scoped ones.
    #
    # @return [Hash{String => String}]
    # @param translations [Hash{String/Symbol => String/Hash}] with multiple
    #   roots allowed
    # @param current_scope for internal use
    #
    # @example
    #   Scope.flatten(en: {common: {hello: "hi"}}, de: {hello: "Hallo"}) #=>
    #     {"en.common.hello" => "hi", "de.hello" => "Hallo"}
    def flatten(translations, current_scope = nil)
      translations.each_with_object({}) do |(key, value), memo|
        scope = current_scope ? join(current_scope, key) : key.to_s
        if value.is_a?(Hash)
          memo.merge!(flatten(value, scope))
        else
          memo[scope] = value
        end
      end
    end

    # Combines each locale with all keys.
    #
    # @return [Array<String>]
    # @param locales [Array<String, Symbol>]
    # @param keys [Array<String, Symbol>]
    #
    # @example
    #   Scope.cross_join([:de, :en], [:hello, :hi]) #=>
    #     ["de.hello", "de.hi", "en.hello", "en.hi"]
    def cross_join(locales, keys)
      locales.flat_map do |locale|
        keys.map { |key| join(locale, key) }
      end
    end
  end
end
