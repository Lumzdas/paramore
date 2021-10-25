class ParameterInspector
  def self.for(params); puts params; end
end

class TestController < ActionController::Base
  param_schema(
    :typed_params,
    test: field({
      id: field(Paramore::Int, null: false),
      name: field(Paramore::StrippedString),
      nested: field({
        email: field(Paramore::SanitizedString),
        deeper: field({
          depths: field([Paramore::Float])
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
    test: field({
      id: field(Paramore::Int, default: 1),
    }, default: {})
  )

  param_schema(
    :with_wild_hash,
    test: field({
      wild: field(Paramore::String => field(Paramore::Int))
    })
  )

  param_schema(
    :almost_flat_params,
    number: field(Paramore::Int, default: 42)
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

  def wild
    ParameterInspector.for(with_wild_hash)
    head 200 and return
  end

  def almost_flat
    ParameterInspector.for(almost_flat_params)
    head 200 and return
  end
end
