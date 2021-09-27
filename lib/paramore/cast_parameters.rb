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
      end

      case field.type
      when Hash
        typecast_hash(field.type, value || {})
      when Array
        typecast_array(field, value)
      else
        if value == '' && !field.allow_empty? && field.nullable?
          nil
        else
          typecast_value(field.type, value)
        end
      end
    end

    def typecast_hash(field, hash)
      field.to_h { |name, field| [name, cast(field, hash[name], name)] }
    end

    def typecast_array(field, array)
      array
        .reject { |unit| unit.to_s == '' && field.compact? }
        .map do |unit|
          cast(Paramore.field(field.type.first, null: true), unit)
        end
    end

    def typecast_value(type, value)
      type.send(Paramore.configuration.type_method_name, value)
    end
  end
end
