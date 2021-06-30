RSpec.describe Paramore::CastParameters, '.run' do
  subject { described_class.run(types_definition, permitted_params) }

  let(:permitted_params) do
    {
      id: '1',
      name: "some name \n",
      metadata: {
        email: 'email@example.com ',
        tags: ['1', '2'],
        deeper: {
          depth: '2'
        },
      },
    }
  end

  let(:types_definition) do
    {
      id: Paratype[Types::Int],
      name: Paratype[Types::Text],
      metadata: Paratype[{
        email: Paratype[Types::Text],
        tags: Paratype[[Types::Int]],
        deeper: Paratype[{
          depth: Paratype[Types::Int],
        }],
      }],
    }
  end

  it 'type casts the parameters' do
    expect(subject).to eq(
      {
        id: 1,
        name: 'some name',
        metadata: {
          email: 'email@example.com',
          tags: [1, 2],
          deeper: {
            depth: 2
          },
        },
      },
    )
  end

  context 'with nil parameters' do
    let(:permitted_params) { {} }

    context 'and nullable types' do
      let(:types_definition) do
        {
          id: Paratype[Types::Int, null: true],
          metadata: Paratype[{
            email: Paratype[Types::Text, null: true],
          }, null: true]
        }
      end

      it 'does not call any of the type classes' do
        expect(Types::Text).not_to receive(:[])
        expect(Types::Int).not_to receive(:[])

        expect(subject).to eq(
          {
            id: nil,
            metadata: nil,
          },
        )
      end
    end

    context 'and non-nullable flat type' do
      let(:permitted_params) { { id: nil } }

      let(:types_definition) do
        {
          id: Paratype[Types::Int],
        }
      end

      it 'raises error' do
        expect(Types::Int).not_to receive(:[])
        expect { subject }.to raise_error(
          an_instance_of(Paramore::NilParameterError).and having_attributes(
            message: a_string_including('`id`')
          )
        )
      end
    end

    context 'and non-nullable array type' do
      let(:permitted_params) { { ary: nil } }

      let(:types_definition) do
        {
          ary: Paratype[[Types::Int]]
        }
      end

      it 'raises error' do
        expect(Types::Int).not_to receive(:[])
        expect { subject }.to raise_error(
          an_instance_of(Paramore::NilParameterError).and having_attributes(
            message: a_string_including('`ary`')
          )
        )
      end
    end

    context 'and non-nullable nested type' do
      let(:permitted_params) { { metadata: nil } }

      let(:types_definition) do
        {
          metadata: Paratype[{
            email: Paratype[Types::Text],
          }]
        }
      end

      it 'raises error' do
        expect(Types::Text).not_to receive(:[])
        expect { subject }.to raise_error(
          an_instance_of(Paramore::NilParameterError).and having_attributes(
            message: a_string_including('`metadata`')
          )
        )
      end
    end
  end
end
