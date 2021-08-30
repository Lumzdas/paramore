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
      types_definition.flat_map do |param_name, field_schema|
        unless field_schema.is_a?(Paramore::FieldSchema)
          raise Paramore::NonFieldSchema.new(param_name, field_schema)
        end

        field_schema.type.is_a?(Hash) ? types(field_schema.type) : field_schema.type
      end.uniq
    end
  end
end
