require_relative 'errors'

module Paramore
  module CastParameters
    module_function
    def run(field, data)
      recursive_merge(cast(field, data, 'data'))
    end

    def recursive_merge(nested_hash_array)
      nested_hash_array.reduce(:merge).map do |name, value|
        if value.is_a?(Array) && value.all? { |_value| _value.is_a?(Hash) }
          { name => recursive_merge(value) }
        else
          { name => value }
        end
      end.reduce(:merge)
    end

    def cast(field, value, name = nil)
      if value.nil?
        if field.nullable? || field.default
          return field.default
        else
          raise Paramore::NilParameter, name
        end
      end

      case field.type
      when Hash
        typecast_hash(field.type, value || {})
      when Array
        typecast_array(field, value)
      else
        typecast_value(field.type, value)
      end
    end

    def typecast_hash(field, hash)
      field.map do |name, field|
        { name => cast(field, hash[name], name) }
      end
    end

    def typecast_array(field, array)
      array
        .reject { |unit| unit.to_s == '' && field.compact? }
        .map { |unit| typecast_value(field.type.first, unit) }
    end

    def typecast_value(type, value)
      type.send(Paramore.configuration.type_method_name, value)
    end
  end
end
