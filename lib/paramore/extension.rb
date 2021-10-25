require_relative 'cast_parameters'
require_relative 'permitted_parameter_argument'

module Paramore
  module Extension
    OPTIONS = %i[
      default
    ].freeze

    def field(*args)
      Paramore.field(*args)
    end

    def param_schema(accessor_name, parameter_configuration)
      unless parameter_configuration.keys.size == 1
        raise ArgumentError,
          "Paramore: exactly one required attribute allowed! Given: #{parameter_configuration.keys}"
      end

      required_parameter_name = parameter_configuration.keys.first
      types_definition = parameter_configuration.values.first

      permitted_parameter_argument =
        if types_definition.is_a?(Paramore::Field)
          Paramore::PermittedParameterArgument.parse(types_definition)
        else
          types_definition
        end

      define_method(accessor_name) do |rails_parameters = params|
        return instance_variable_get("@#{accessor_name}") if instance_variable_defined?("@#{accessor_name}")

        if rails_parameters[required_parameter_name].nil? && types_definition.default?
          instance_variable_set("@#{accessor_name}", types_definition.default)
          return instance_variable_get("@#{accessor_name}")
        end

        required_params = rails_parameters.require(required_parameter_name)
        should_permit = permitted_parameter_argument.any? && required_params.is_a?(ActionController::Parameters)

        permitted_params =
          if should_permit
            required_params.permit(permitted_parameter_argument)
          else
            required_params
          end

        parameter_values =
          if types_definition.is_a?(Paramore::Field)
            if should_permit
              permitted_params.merge(
                Paramore::CastParameters.run(
                  types_definition,
                  permitted_params.to_hash.with_indifferent_access
                )
              ).permit!
            else
              Paramore::CastParameters.run(types_definition, permitted_params)
            end
          else
            permitted_params.permit!
          end

        instance_variable_set("@#{accessor_name}", parameter_values)
      end
    end
  end
end
