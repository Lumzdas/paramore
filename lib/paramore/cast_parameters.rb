require_relative 'errors'

module Paramore
  class CastParameters
    attr_accessor :root_field, :data, :options

    def initialize(field, data, options)
      @root_field = field
      @data = data
      @options = options
    end

    def self.run(field, data, options = {})
      new(field, data, options).run
    end

    def run
      cast(root_field, data, nil)
    end

    def cast(field, value, key, namespace = nil)
      full_name = [namespace, key].select(&:present?).join('.')

      if value.nil?
        return field.default if field.nullable? || field.default?

        raise Paramore::NilParameter, full_name
      elsif value == ''
        return typecast_value(field.type, '', full_name) if field.allow_empty?
        return field.default if field.default?
        return if field.nullable?

        raise Paramore::NilParameter, full_name
      end

      case field.type
      when Hash
        typecast_hash(field, value || {}, full_name)
      when Array
        typecast_array(field, value, full_name)
      else
        typecast_value(field.type, value, full_name)
      end
    end

    def typecast_hash(field, hash, full_name)
      raise Paramore::HashExpected.new(full_name, hash) unless hash.is_a?(Hash)

      result =
        if field.wildly_keyed_hash?
          cast_wild_hash(field, hash, full_name)
        else
          cast_regular_hash(field, hash, full_name)
        end

      field.compact? ? result.compact : result
    end

    def typecast_array(field, array, full_name)
      raise Paramore::ArrayExpected.new(full_name, array) unless array.is_a?(Array)

      result =
        array
        .reject { |unit| unit.to_s == '' && field.compact? }
        .map { |unit| cast(Paramore.field(field.type.first, null: true), unit, nil, full_name) }

      field.compact? ? result.compact : result
    end

    def typecast_value(type, value, full_name)
      type.send(Paramore.configuration.type_method_name, value)
    rescue StandardError => e
      raise "Tried casting #{Paramore::ErrorFieldName(full_name)}, but \"#{e}\" was raised!"
    end

    def cast_wild_hash(field, hash, full_name)
      value_field = field.type.values.first
      key_type = field.type.keys.first

      hash.to_h do |inner_key, value|
        [
          typecast_value(key_type, inner_key, nil),
          cast(value_field, value, inner_key, full_name)
        ]
      end
    end

    def cast_regular_hash(field, hash, full_name)
      if options[:no_extra_keys]
        extra = hash.keys - field.type.keys
        raise "Found extra keys in #{Paramore::ErrorFieldName(full_name)}: #{extra}!" if extra.any?
      end

      field
        .type
        .reject { |inner_key, value_field| missing_and_optional?(hash, inner_key, value_field) }
        .to_h do |inner_key, value_field|
          [inner_key, cast(value_field, hash[inner_key], inner_key, full_name)]
        end
    end

    def missing_and_optional?(hash, key, field)
      !hash.key?(key) && !field.required?
    end
  end
end
