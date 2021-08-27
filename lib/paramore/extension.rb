require_relative 'validate'
require_relative 'cast_parameters'
require_relative 'permitted_parameter_argument'

module Paramore
  module Extension
    OPTIONS = %i[
      default
    ].freeze

    def paramorize(accessor_name, configuration)
      parameter_configuration = configuration.except(*OPTIONS)

      unless parameter_configuration.keys.size == 1
        raise ArgumentError,
          "Paramore: exactly one required attribute allowed! Given: #{parameter_configuration.keys}"
      end

      required_parameter_name = parameter_configuration.keys.first
      types_definition = parameter_configuration.values.first

      Paramore::Validate.run(types_definition) if types_definition.is_a?(Hash)

      permitted_parameter_argument =
        if types_definition.is_a?(Hash)
          Paramore::PermittedParameterArgument.parse(types_definition)
        else
          types_definition
        end

      define_method(accessor_name) do |rails_parameters = params|
        return instance_variable_get("@#{accessor_name}") if instance_variable_defined?("@#{accessor_name}")

        if rails_parameters[required_parameter_name].nil? && configuration[:default]
          instance_variable_set("@#{accessor_name}", configuration[:default])
          return instance_variable_get("@#{accessor_name}")
        end

        permitted_params = rails_parameters
          .require(required_parameter_name)
          .permit(permitted_parameter_argument)

        parameter_values =
          if types_definition.is_a?(Hash)
            permitted_params.merge(
              Paramore::CastParameters.run(types_definition, permitted_params)
            ).permit!
          else
            permitted_params.permit!
          end

        instance_variable_set("@#{accessor_name}", parameter_values)
      end
    end
  end
end
