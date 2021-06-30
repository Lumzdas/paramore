require_relative 'errors'

module Paramore
  module CastParameters
    module_function
    def run(types_definition, permitted_params)
      recursive_merge(
        recursive_typecast(
          types_definition, permitted_params
        )
      )
    end

    def recursive_merge(nested_hash_array)
      nested_hash_array.reduce(:merge).map do |param_name, value|
        if value.is_a?(Array) && value.all? { |_value| _value.is_a?(Hash) }
          { param_name => recursive_merge(value) }
        else
          { param_name => value }
        end
      end.reduce(:merge)
    end

    def recursive_typecast(types_definition, permitted_params)
      types_definition.map do |param_name, definition|
        value = permitted_params[param_name]

        if value.nil?
          if definition.nullable?
            next { param_name => nil }
          else
            raise Paramore::NilParameter, param_name
          end
        end

        { param_name => cast(definition, value) }
      end
    end

    def cast(definition, value)
      case definition.type
      when Hash
        recursive_typecast(definition.type, value || {})
      when Array
        typecast_array(definition, value)
      else
        typecast_value(definition.type, value)
      end
    end

    def typecast_array(definition, array)
      array
        .reject { |unit| unit.to_s == '' && definition.compact? }
        .map do |unit|
          if unit.to_s != '' || definition.use_empty_strings?
            typecast_value(definition.type.first, unit)
          end
        end
    end

    def typecast_value(type, value)
      type.send(Paramore.configuration.type_method_name, value)
    end
  end
end
