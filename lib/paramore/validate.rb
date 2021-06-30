# frozen_string_literal: true

module Paramore
  module Validate
    module_function
    def run(param_definition, format_definition)
      unless param_definition.keys.size == 1
        raise ArgumentError,
          "Paramore: exactly one required attribute allowed! Given: #{param_definition.keys}"
      end

      return unless format_definition

      types(format_definition).each do |type|
          unless type.respond_to?(Paramore.configuration.type_method_name)
            raise NoMethodError,
              "Paramore: type `#{type}` does not respond to " +
              "`#{Paramore.configuration.type_method_name}`!"
          end
      end
    end

    def types(format_definition)
      format_definition.flat_map do |_, type|
        type.kind_of?(Hash) ?  types(type) : type
      end.uniq
    end
  end
end
