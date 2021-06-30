class Paratype
  def self.[](given_type, null: false, empty: false, compact: false)
    self.new(given_type, null: null, empty: empty, compact: compact)
  end

  def initialize(given_type, null:, empty:, compact:)
    @given_type = given_type
    @nullable = null
    @empty = empty
    @compact = compact
  end

  def compact?
    compact
  end

  def nullable?
    nullable
  end

  def use_empty_strings?
    empty
  end

  def type
    given_type
  end

  private

  attr_reader :given_type, :nullable, :empty, :compact
end
