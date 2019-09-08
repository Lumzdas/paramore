# frozen_string_literal: true

require_relative 'validate'
require_relative 'format'

module Paramore
  module Extension
    def declare_params(accessor_name, param_definition)
      format_definition = param_definition.delete(:format)

      Validate.run(param_definition, format_definition)

      required = param_definition.keys.first
      permitted = param_definition.values.first

      define_method(accessor_name) do |rails_parameters = params|
        return instance_variable_get("@#{accessor_name}") if instance_variable_defined?("@#{accessor_name}")

        permitted_params = rails_parameters.require(required).permit(permitted)

        instance_variable_set(
          "@#{accessor_name}",
          permitted_params.merge(Format.run(format_definition, permitted_params)).permit!
        )
      end
    end
  end
end
