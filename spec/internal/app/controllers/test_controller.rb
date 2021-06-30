class ParameterInspector
  def self.for(params); puts params; end
end

class TestController < ActionController::Base
  paramorize :typed_params,
    test: {
      id: Paratype[Paramore::Int, null: false],
      name: Paratype[Paramore::StrippedString],
      nested: Paratype[{
        email: Paratype[Paramore::SanitizedString],
        deeper: Paratype[{
          depths: Paratype[[Paramore::Float]]
        }]
      }]
    }

  paramorize :untyped_params,
    test: [:id, :name, nested: [:email, deeper: [depths: []]]]

  def typed
    ParameterInspector.for(typed_params)
    head 200 and return
  end

  def untyped
    ParameterInspector.for(untyped_params)
    head 200 and return
  end
end
