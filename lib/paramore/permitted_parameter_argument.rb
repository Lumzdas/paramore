module Paramore
  module PermittedParameterArgument
    module_function

    def parse(types_definition)
      merge_hashes(
        types_definition.map do |key, definition|
          case definition
          when Hash
            { key => merge_hashes(parse(definition)) }
          when Paratype
            case definition.type
            when Array
              { key => [] }
            when Hash
              { key => merge_hashes(parse(definition.type)) }
            else
              key
            end
          end
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
