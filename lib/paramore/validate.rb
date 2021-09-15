module Paramore
  module Validate
    module_function

    def run(root_field)
      types(root_field.type).uniq.each do |type|
        unless type.respond_to?(Paramore.configuration.type_method_name)
          raise NoMethodError,
            "Paramore: type `#{type}` does not respond to " +
            "`#{Paramore.configuration.type_method_name}`!"
        end
      end
    end

    def types(type)
      case type
      when Hash
        hash_types(type)
      when Array
        type.flat_map { |subtype| types(subtype) }
      else
        [type]
      end
    end

    def hash_types(hash)
      hash.flat_map do |param_name, field|
        raise Paramore::NonField.new(param_name, field) unless field.is_a?(Paramore::Field)

        field.type.is_a?(Hash) ? types(field.type) : field.type
      end.uniq
    end
  end
end
