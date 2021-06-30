require_relative 'validate'
require_relative 'cast_parameters'
require_relative 'permitted_parameter_argument'

module Paramore
  module Extension
    def paramorize(accessor_name, parameter_configuration)
      unless parameter_configuration.keys.size == 1
        raise ArgumentError,
          "Paramore: exactly one required attribute allowed! Given: #{param_definition.keys}"
      end

      required_parameter_name = parameter_configuration.keys.first
      types_definition = parameter_configuration.values.first

      Paramore::Validate.run(types_definition) if types_definition.is_a?(Hash)

      define_method(accessor_name) do |rails_parameters = params|
        return instance_variable_get("@#{accessor_name}") if instance_variable_defined?("@#{accessor_name}")

        permitted_parameter_argument =
          if types_definition.is_a?(Hash)
            Paramore::PermittedParameterArgument.parse(types_definition)
          else
            types_definition
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
