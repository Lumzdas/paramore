# frozen_string_literal: true

module Types
  module IntArray
    module_function
    def [](input)
      input.map(&:to_i)
    end
  end
end
