require_relative 'errors'

module Paramore
  module CastParameters
    module_function
    def run(field, data)
      cast(field, data, 'data')
    end

    def cast(field, value, name = nil)
      if value.nil?
        if field.nullable? || field.default?
          return field.default
        else
          raise Paramore::NilParameter, name
        end
      elsif value == ''
        if field.allow_empty?
          return typecast_value(field.type, '', name)
        elsif field.default?
          return field.default
        elsif field.nullable?
          return
        else
          raise Paramore::NilParameter, name
        end
      end

      case field.type
      when Hash
        typecast_hash(field, value || {}, name)
      when Array
        typecast_array(field, value, name)
      else
        typecast_value(field.type, value, name)
      end
    end

    def typecast_hash(field, hash, name)
      raise Paramore::HashExpected.new(name, hash) unless hash.is_a?(Hash)

      result =
        if field.wildly_keyed_hash?
          value_field = field.type.values.first
          key_type = field.type.keys.first
          hash.to_h do |name, value|
            [typecast_value(key_type, name, nil), cast(value_field, value, name)]
          end
        else
          field
            .type
            .reject { |name, value_field| missing_and_optional?(hash, name, value_field) }
            .to_h { |name, value_field| [name, cast(value_field, hash[name], name)] }
        end


      field.compact? ? result.compact : result
    end

    def typecast_array(field, array, name)
      raise Paramore::ArrayExpected.new(name, array) unless array.is_a?(Array)

      result = array
        .reject { |unit| unit.to_s == '' && field.compact? }
        .map { |unit| cast(Paramore.field(field.type.first, null: true), unit) }

      field.compact? ? result.compact : result
    end

    def typecast_value(type, value, name)
      type.send(Paramore.configuration.type_method_name, value)
    end

    def missing_and_optional?(hash, name, field)
      !hash.key?(name) && !field.required?
    end
  end
end
