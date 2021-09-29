class Paramore::NilParameter < StandardError
  def initialize(param_name)
    super("Received a nil `#{param_name}`, but it's type is non nullable!")
  end
end

class Paramore::NonField < StandardError
  def initialize(param_name, type)
    super("`#{param_name}` defined as a `#{type.class}`, expected a call of `Paramore.field()`! Perhaps you declared a plain hash instead of Paramore.field({})?")
  end
end

class Paramore::HashExpected < StandardError
  def initialize(param_name, param)
    super("Expected `#{param_name}` to be a hash, received #{param.class} instead!")
  end
end

class Paramore::ArrayExpected < StandardError
  def initialize(param_name, param)
    super("Expected `#{param_name}` to be an array, received #{param.class} instead!")
  end
end

class Paramore::HashTooWild < StandardError
  def initialize(hash)
    super("A hash field with a type as key may not contain any more entries! (so, eg.: { String => field } is ok, but { String => field, user_id: field } is not)")
  end
end
