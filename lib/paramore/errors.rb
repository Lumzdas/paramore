class Paramore::NilParameterError < StandardError
  def initialize(param_name)
    super("Received a nil `#{param_name}`, but it's type is non nullable!")
  end
end

class Paramore::NonParatypeError < StandardError
  def initialize(param_name, type)
    super("`#{param_name}` defined as a `#{type.class}`, expected `Paratype`! Perhaps you tried making a hash instead of Paratype[{}]?")
  end
end
