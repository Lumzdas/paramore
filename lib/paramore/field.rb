require_relative 'validate'

module Paramore
  class Field
    DEFAULT_OPTIONS = {
      null: false,
      compact: false,
      default: nil,
      empty: false,
      required: true,
    }.freeze

    def initialize(given_type, null:, compact:, default:, empty:, required:)
      @given_type = given_type
      @nullable = null
      @compact = compact
      @allow_empty = empty
      @default = default
      @required = required
    end

    def required?
      @required
    end

    def allow_empty?
      @allow_empty
    end

    def default?
      !@default.nil?
    end

    def default
      @default.is_a?(Proc) ? @default.call : @default
    end

    def compact?
      @compact
    end

    def nullable?
      @nullable
    end

    def type
      @given_type
    end

    def wildly_keyed_hash?
      type.is_a?(Hash) && self.class.wildly_keyed_hash?(type)
    end

    def validate!
      Paramore::Validate.run(self)
    end

    def self.wildly_keyed_hash?(hash)
      hash.keys.any? { |key| [Class, Module].include?(key.class) }
    end
  end
end
