module Mova
  module Storage
    # Allows to wrap several storages and treat them as one. All methods are called on
    # each storage in order defined in the initializer.
    #
    # @since 0.1.0
    class Chain
      attr_reader :storages

      def initialize(*storages)
        @storages = storages

        # Performance optimizations:
        # * replace loop with OR operator in places where we know beforehand
        #   all iterated elements (storages)
        # * avoid reading from the next storage if possible
        instance_eval <<-EOM, __FILE__, __LINE__ + 1
          def read(key)
            #{
              calls_to_each_storage = storages.map.each_with_index do |s, i|
                "Mova.presence(storages[#{i}].read(key))"
              end
              calls_to_each_storage.join(" || ")
            }
          end

          def read_multi(*keys)
            #{
              initialize_results = storages.map.each_with_index do |s, i|
                "results#{i} = nil"
              end
              initialize_results.join("\n")
            }
            keys.each_with_object({}) do |key, memo|
              result = \
                #{
                  calls_to_each_storage = storages.map.each_with_index do |s, i|
                    "Mova.presence((results#{i} ||= storages[#{i}].read_multi(*keys))[key])"
                  end
                  calls_to_each_storage.join(" || ")
                }
              memo[key] = result if result
            end
          end
        EOM
      end

      # @!method read(key)
      # @return [String, nil] first non-empty value while trying each storage in order defined
      #   in the initializer.
      # @param key [String]
      #
      # @example
      #   storage1.write("hello", "ruby")
      #   storage2.write("hello", "world")
      #   storage2.write("bye", "war")
      #   chain = Mova::Storage::Chain.new(storage1, storage2)
      #   chain.read("hello") #=> "ruby"
      #   chain.read("bye") #=> "war"
      #
      # @!parse
      #   def read(key)
      #     Mova.presence(storages[0].read(key)) || Mova.presence(storages[1].read(key)) || etc
      #   end

      # @!method read_multi(*keys)
      # @return [Hash{String => String}] composed result of all non-empty values. Hashes are merged
      #   backwards, so results from a first storage win over results from next one. However,
      #   non-empty value wins over empty one.
      # @param keys [*Array<String>]
      #
      # @example
      #   storage1.write("hello", "ruby")
      #   storage1.write("empty", "")
      #   storage2.write("hello", "world")
      #   storage2.write("empty", "not so much")
      #   storage2.write("bye", "war")
      #   chain = Mova::Storage::Chain.new(storage1, storage2)
      #   chain.read_multi("hello", "bye", "empty") #=> {"hello" => "ruby", "bye" => "war", "empty" => "not so much"}
      #
      # @!parse
      #  def read_multi(*keys)
      #    results0 = nil
      #    results1 = nil
      #    etc
      #    keys.each_with_object({}) do |key, memo|
      #      result =
      #        Mova.presence((results0 ||= storages[0].read_multi(*keys))[key]) ||
      #        Mova.presence((results1 ||= storages[1].read_multi(*keys))[key]) || etc
      #      memo[key] = result if result
      #    end
      #  end

      # @return [void]
      # @param key [String]
      # @param value [String, nil]
      #
      # @note Each storage will receive #write. Use {Readonly} if you wish to protect
      #   certain storages.
      def write(key, value)
        storages.each { |s| s.write(key, value) }
      end

      # @return [void]
      #
      # @note Each storage will receive #clear. Use {Readonly} if you wish to protect
      #   certain storages.
      def clear
        storages.each { |s| s.clear }
      end

      # @return [Boolean]
      # @param key [String]
      def exist?(key)
        storages.any? { |s| s.exist?(key) }
      end

      # @private
      def inspect
        "<##{self.class.name} storages=#{storages.inspect}>"
      end
    end
  end
end
