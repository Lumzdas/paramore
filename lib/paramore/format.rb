# frozen_string_literal: true

module Paramore
  module Format
    module_function
    def run(format_definition, permitted_params)
      return {} unless format_definition

      recursive_merge(
        recursive_typecast(
          format_definition, permitted_params
        )
      )
    end

    def recursive_merge(nested_hash_array)
      nested_hash_array.reduce(:merge).map do |param_name, value|
        if value.kind_of?(Array) && value.all? { |_value| _value.kind_of?(Hash) }
          { param_name => recursive_merge(value) }
        else
          { param_name => value }
        end
      end.reduce(:merge)
    end

    def recursive_typecast(format_definition, permitted_params)
      format_definition.map do |param_name, type|
        next {} unless permitted_params[param_name]

        if type.kind_of?(Hash)
          { param_name => recursive_typecast(type, permitted_params[param_name]) }
        else
          { param_name => typecast_value(permitted_params[param_name], type) }
        end
      end
    end

    def typecast_value(value, type)
      type.send(Paramore.configuration.type_method_name, value)
    end
  end
end
