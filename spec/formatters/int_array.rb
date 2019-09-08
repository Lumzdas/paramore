# frozen_string_literal: true

module Formatter
  module IntArray
    module_function
    def run(input)
      input.map(&:to_i)
    end
  end
end
