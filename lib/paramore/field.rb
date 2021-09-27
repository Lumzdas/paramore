module Paramore
  class Field
    DEFAULT_OPTIONS = {
      null: false,
      compact: false,
      default: nil,
      empty: true,
    }.freeze

    def initialize(given_type, null:, compact:, default:, empty:)
      @given_type = given_type
      @nullable = null
      @compact = compact
      @allow_empty = empty
      @default = default
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
  end
end
