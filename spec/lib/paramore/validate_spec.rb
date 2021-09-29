RSpec.describe Paramore::Validate, '.run' do
  subject { described_class.run(types_definition) }

  let(:types_definition) do
    Paramore.field({
      id: Paramore.field(Types::Int),
      metadata: Paramore.field({
        tags: Paramore.field([Types::Int]),
      }),
    })
  end

  it 'does not raise' do
    expect { subject }.not_to raise_error
  end

  context 'with miswritten method name' do
    let(:types_definition) do
      Paramore.field({
        id: Paramore.field(Types::Typo),
      })
    end

    it 'raises' do
      expect { subject }.to raise_error(
        NoMethodError,
        'Paramore: type `Types::Typo` does not respond to `[]`!'
      )
    end
  end

  context 'with hash instead of Paramore.field({})' do
    let(:types_definition) do
      Paramore.field({
        extra: {
          email: Paramore.field(Types::Text)
        }
      })
    end

    it 'raises' do
      expect { subject }.to raise_error(
        Paramore::NonField,
        '`extra` defined as a `Hash`, expected a call of `Paramore.field()`! Perhaps you declared a plain hash instead of Paramore.field({})?'
      )
    end
  end

  context 'with a wild hash' do
    let(:types_definition) do
      Paramore.field({
        Paramore::String => Paramore.field(Paramore::String)
      })
    end

    it 'does not raise' do
      expect { subject }.not_to raise_error
    end
  end

  context 'with an overly wild hash' do
    let(:types_definition) do
      Paramore.field({
        Paramore::String => Paramore.field(Paramore::String),
        Paramore::Int => Paramore.field(Paramore::Int)
      })
    end

    it 'raises' do
      expect { subject }.to raise_error(
        Paramore::HashTooWild,
        'A hash field with a type as key may not contain any more entries! (so, eg.: { String => field } is ok, but { String => field, user_id: field } is not)'
      )
    end
  end
end
