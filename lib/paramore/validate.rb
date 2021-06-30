module Paramore
  module Validate
    module_function

    def run(types_definition)
      types(types_definition).each do |type|
        unless type.respond_to?(Paramore.configuration.type_method_name)
          raise NoMethodError,
            "Paramore: type `#{type}` does not respond to " +
            "`#{Paramore.configuration.type_method_name}`!"
        end
      end
    end

    def types(types_definition)
      types_definition.flat_map do |param_name, paratype|
        unless paratype.is_a?(Paratype)
          raise Paramore::NonParatypeError.new(param_name, paratype)
        end

        paratype.type.is_a?(Hash) ? types(paratype.type) : paratype.type
      end.uniq
    end
  end
end
