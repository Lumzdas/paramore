module Paramore
  module TypeRegexes
    INTEGER_REGEX = /^-{0,1}\d+$/
    FLOAT_REGEX = /^-{0,1}\d+(\.\d*){0,1}$/
  end

  module BigDecimal
    module_function
    def [](input)
      raise ArgumentError "#{input} is not a BigDecimal!" unless input.to_s.match?(TypeRegexes::FLOAT_REGEX)

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
      raise ArgumentError "#{input} is not a Float!" unless input.to_s.match?(TypeRegexes::FLOAT_REGEX)

      input.to_f
    end
  end

  module Int
    module_function
    def [](input)
      raise ArgumentError, "#{input} is not an Integer!" unless input.to_s.match?(TypeRegexes::INTEGER_REGEX)

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

  module File
    VALID_CLASSES = [
      File,
      StringIO,
      Rack::Test::UploadedFile,
      ActionDispatch::Http::UploadedFile,
    ].freeze

    module_function
    def [](input)
      raise "#{input.class} is not a file!" unless input.class.in?(VALID_CLASSES)

      input
    end
  end
end
