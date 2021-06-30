# frozen_string_literal: true

module Types
  module Int
    module_function
    def [](input)
      input.to_i
    end
  end
end
