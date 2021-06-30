require_relative 'extension'

return unless defined?(Rails)

module Paramore
  class Railtie < Rails::Railtie
    initializer 'paramore.action_controller' do
      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.extend(Paramore::Extension)
        ActionController::API.extend(Paramore::Extension)
      end
    end
  end
end
