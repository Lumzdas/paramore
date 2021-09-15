module Paramore
  class Field
    DEFAULT_OPTIONS = {
      null: false,
      compact: false,
      default: nil,
    }.freeze

    def initialize(given_type, null:, compact:, default:)
      @given_type = given_type
      @nullable = null
      @compact = compact
      @default = default
    end

    def default
      @default
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
