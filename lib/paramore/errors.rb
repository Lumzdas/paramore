class Paramore::NilParameter < StandardError
  def initialize(param_name)
    super("Received a nil `#{param_name}`, but it's type is non nullable!")
  end
end

class Paramore::NonFieldSchema < StandardError
  def initialize(param_name, type)
    super("`#{param_name}` defined as a `#{type.class}`, expected a call of `Paramore.field()`! Perhaps you declared a plain hash instead of Paramore.field({})?")
  end
end
