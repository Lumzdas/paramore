# frozen_string_literal: true

module Paramore
  module Validate
    module_function
    def run(param_definition, format_definition)
      unless param_definition.keys.size == 1
        raise ArgumentError,
          "Paramore: exactly one required attribute allowed! Given: #{param_definition.keys}"
      end

      return unless format_definition

      formatter_names(format_definition).each do |formatter_name|
        formatter =
          begin
            Paramore::Format.formatter_for(formatter_name)
          rescue NameError => e
            raise NameError, "Paramore: formatter `#{formatter_name}` is undefined! #{e}"
          end

          unless formatter.respond_to?(Paramore.configuration.formatter_method_name)
            raise NoMethodError,
              "Paramore: formatter `#{formatter_name}` does not respond to " +
              "`#{Paramore.configuration.formatter_method_name}`!"
          end
      end
    end

    def formatter_names(format_definition)
      format_definition.flat_map do |_, value|
        if value.kind_of?(Hash)
          formatter_names(value)
        else
          value
        end
      end.uniq
    end
  end
end
