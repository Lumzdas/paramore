class ParameterInspector
  def self.for(params); puts params; end
end

class TestController < ActionController::Base
  param_schema(
    :typed_params,
    test: Paramore.field({
      id: Paramore.field(Paramore::Int, null: false),
      name: Paramore.field(Paramore::StrippedString),
      nested: Paramore.field({
        email: Paramore.field(Paramore::SanitizedString),
        deeper: Paramore.field({
          depths: Paramore.field([Paramore::Float])
        })
      })
    })
  )

  param_schema(
    :untyped_params,
    test: [:id, :name, nested: [:email, deeper: [depths: []]]]
  )

  param_schema(
    :with_default,
    test: Paramore.field({
      id: Paramore.field(Paramore::Int, default: 1),
    }, default: {})
  )

  def typed
    ParameterInspector.for(typed_params)
    head 200 and return
  end

  def untyped
    ParameterInspector.for(untyped_params)
    head 200 and return
  end

  def default
    ParameterInspector.for(with_default)
    head 200 and return
  end
end
