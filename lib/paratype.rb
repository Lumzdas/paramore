class Paratype
  def self.[](given_type, null: false)
    self.new(given_type, null: null)
  end

  def initialize(given_type, null:)
    @given_type = given_type
    @nullable = null
  end

  def nullable?
    nullable
  end

  def type
    given_type
  end

  private

  attr_reader :given_type, :nullable
end
