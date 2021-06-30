class Paramore::NilParameter < StandardError
  def initialize(param_name)
    super("Received a nil `#{param_name}`, but it's type is non nullable!")
  end
end

class Paramore::NonParatype < StandardError
  def initialize(param_name, type)
    super("`#{param_name}` defined as a `#{type.class}`, expected `Paratype`! Perhaps you declared a plain hash instead of Paratype[{}]?")
  end
end
