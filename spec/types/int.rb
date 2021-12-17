module Types
  module Int
    module_function
    def [](input)
      raise ArgumentError, "#{input} is not an integer!" unless input.to_s.match?(/^-{0,1}\d*$/)

      input.to_i
    end
  end
end
