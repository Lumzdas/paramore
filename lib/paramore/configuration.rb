# frozen_string_literal: true

module Paramore
  class Configuration
    DEFAULT_FORMATTER_NAMESPACE = 'Formatter'
    DEFAULT_FORMATTER_METHOD_NAME = 'run'

    attr_accessor :formatter_namespace, :formatter_method_name

    def initialize
      @formatter_namespace = DEFAULT_FORMATTER_NAMESPACE
      @formatter_method_name = DEFAULT_FORMATTER_METHOD_NAME
    end
  end
end
