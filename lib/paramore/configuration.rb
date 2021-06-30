module Paramore
  class Configuration
    DEFAULT_TYPE_METHOD_NAME = :[]

    attr_accessor :type_method_name

    def initialize
      @type_method_name = DEFAULT_TYPE_METHOD_NAME
    end
  end
end
