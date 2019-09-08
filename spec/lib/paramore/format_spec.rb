# frozen_string_literal: true

RSpec.describe Paramore::Format, '.run' do
  subject { described_class.run(format_definition, permitted_params) }

  let(:permitted_params) do
    {
      id: '1',
      name: "some name \n",
      metadata: {
        email: 'email@example.com ',
        tags: ['1', '2'],
        deeper: {
          depth: '2'
        }
      }
    }
  end

  let(:format_definition) do
    {
      id: :Int,
      name: :Text,
      metadata: {
        email: :Text,
        tags: :IntArray,
        deeper: {
          depth: :Int,
        },
        unreceived: {
          unreceived: :Int
        }
      },
    }
  end

  it 'formats the parameters' do
    expect(subject).to eq(
      {
        id: 1,
        name: 'some name',
        metadata: {
          email: 'email@example.com',
          tags: [1, 2],
          deeper: {
            depth: 2
          }
        }
      }
    )
  end
end
