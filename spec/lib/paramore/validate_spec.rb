# frozen_string_literal: true

RSpec.describe Paramore::Validate, '.run' do
  subject { described_class.run(param_definition, format_definition) }

  let(:param_definition) { { item: [:id, :name, metadata: [tags: []]] } }

  context 'without format_definition' do
    let(:format_definition) { nil }

    it 'does not raise' do
      expect { subject }.not_to raise_error
    end

    context 'and empty param_definition' do
      let(:param_definition) { {} }

      it 'raises' do
        expect { subject }.to raise_error(
          ArgumentError,
          'Paramore: exactly one required attribute allowed! Given: []'
        )
      end
    end

    context 'and excessive param_definition' do
      let(:param_definition) { { item: [:id], user: [:id] } }

      it 'raises' do
        expect { subject }.to raise_error(
          ArgumentError,
          'Paramore: exactly one required attribute allowed! Given: [:item, :user]'
        )
      end
    end
  end

  context 'with format_definition' do
    let(:format_definition) { { id: Types::Int, metadata: { tags: :IntArray } } }

    it 'does not raise' do
      expect { subject }.not_to raise_error
    end

    context 'with miswritten method name' do
      let(:format_definition) { { id: Types::Typo } }

      it 'raises' do
        expect { subject }.to raise_error(
          NoMethodError,
          'Paramore: type `Types::Typo` does not respond to `[]`!'
        )
      end
    end
  end
end
