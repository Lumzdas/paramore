module Paramore
  module PermittedParameterArgument
    module_function

    def parse(field)
      parse_type(field.type)
    end

    def parse_type(type)
      merge_hashes(
        case type
        when Array
          parse_type(type.first)
        when Hash
          type.map do |name, field|
            case field.type
            when Array, Hash
              { name => parse_type(field.type) }
            else
              name
            end
          end
        else
          []
        end
      )
    end

    def merge_hashes(parsed)
      (flat_parameters(parsed) + nested_parameters(parsed)).compact
    end

    def flat_parameters(parsed)
      parsed.select { |arg| arg.is_a?(Symbol) }
    end

    def nested_parameters(parsed)
      [parsed.reject { |arg| arg.is_a?(Symbol) }.reduce(:merge)]
    end
  end
end
