# frozen_string_literal: true

module Paramore
  module Format
    module_function
    def run(format_definition, permitted_params)
      return {} unless format_definition

      recursive_merge(
        recursive_format(
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

    def recursive_format(format_definition, permitted_params)
      format_definition.map do |param_name, value|
        next {} unless permitted_params[param_name]

        if value.kind_of?(Hash)
          { param_name => recursive_format(value, permitted_params[param_name]) }
        else
          { param_name => formatted_value(permitted_params[param_name], formatter_for(value)) }
        end
      end
    end

    def formatted_value(value, formatter)
      formatter.send(Paramore.configuration.formatter_method_name, value)
    end

    def formatter_for(formatter_name)
      Object.const_get(
        [Paramore.configuration.formatter_namespace, formatter_name].compact.join('::'),
        false # inherit=false - only get exact match
      )
    end
  end
end
