RSpec.describe Paramore::Validate, '.run' do
  subject { described_class.run(types_definition) }

  let(:types_definition) do
    {
      id: Paratype[Types::Int],
      metadata: Paratype[{
        tags: Paratype[[Types::Int]]
      }]
    }
  end

  it 'does not raise' do
    expect { subject }.not_to raise_error
  end

  context 'with miswritten method name' do
    let(:types_definition) do
      {
        id: Paratype[Types::Typo]
      }
    end

    it 'raises' do
      expect { subject }.to raise_error(
        NoMethodError,
        'Paramore: type `Types::Typo` does not respond to `[]`!'
      )
    end
  end

  context 'with hash instead of Paratype[{}]' do
    let(:types_definition) do
      {
        extra: {
          email: Paratype[Types::Text]
        }
      }
    end

    it 'raises' do
      expect { subject }.to raise_error(
        Paramore::NonParatype,
        '`extra` defined as a `Hash`, expected `Paratype`! Perhaps you declared a plain hash instead of Paratype[{}]?'
      )
    end
  end
end
