module Paramore
  module BigDecimal
    module_function
    def [](input)
      BigDecimal(input)
    end
  end

  module Boolean
    TRUTHY_TEXT_VALUES = %w[t true 1]

    module_function
    def [](input)
      input.in?(TRUTHY_TEXT_VALUES)
    end
  end

  module Float
    module_function
    def [](input)
      input.to_f
    end
  end

  module Int
    module_function
    def [](input)
      input.to_i
    end
  end

  module String
    module_function
    def [](input)
      input.to_s
    end
  end

  module StrippedString
    module_function
    def [](input)
      input.to_s.strip
    end
  end

  module SanitizedString
    module_function
    def [](input)
      Paramore::StrippedString[input].squeeze(' ')
    end
  end

  module Date
    module_function
    def [](input)
      ::Date.parse(input)
    end
  end
end
