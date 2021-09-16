RSpec.describe Paramore::CastParameters, '.run' do
  subject { described_class.run(field, params) }

  let(:params) do
    {
      id: '1',
      name: "some name \n",
      metadata: {
        email: 'email@example.com ',
        tags: ['1', '2', nil],
        deeper: {
          depth: '2'
        },
      },
    }
  end

  let(:field) do
    Paramore.field({
      id: Paramore.field(Types::Int),
      name: Paramore.field(Types::Text),
      metadata: Paramore.field({
        email: Paramore.field(Types::Text),
        tags: Paramore.field([Types::Int]),
        deeper: Paramore.field({
          depth: Paramore.field(Types::Int),
        }),
      }),
    })
  end

  it 'type casts the parameters' do
    expect(subject).to eq(
      {
        id: 1,
        name: 'some name',
        metadata: {
          email: 'email@example.com',
          tags: [1, 2, nil],
          deeper: {
            depth: 2
          },
        },
      },
    )
  end

  context 'when compacting arrays' do
    let(:field) do
      Paramore.field({
        metadata: Paramore.field({
          tags: Paramore.field([Types::Int], compact: true),
        }),
      })
    end

    it 'casts nil to int' do
      expect(subject).to eq(
        {
          metadata: {
            tags: [1, 2],
          },
        },
      )
    end
  end

  context 'with am array of hashes' do
    let(:params) do
      [
        { a: 1 },
        { a: 2 },
        { a: 3, b: 1 },
      ]
    end

    let(:field) do
      Paramore.field([{
        a: Paramore.field(Types::Int),
      }])
    end

    it 'successfully parses the array' do
      expect(subject).to eq([
        { a: 1 },
        { a: 2 },
        { a: 3 },
      ])
    end
  end

  context 'with nil parameters' do
    let(:params) { {} }

    context 'and nullable types' do
      let(:field) do
        Paramore.field({
          id: Paramore.field(Types::Int, null: true),
          metadata: Paramore.field({
            email: Paramore.field(Types::Text, null: true),
          }, null: true),
        })
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
      let(:params) { { id: nil } }

      let(:field) do
        Paramore.field({
          id: Paramore.field(Types::Int),
        })
      end

      it 'raises error' do
        expect(Types::Int).not_to receive(:[])
        expect { subject }.to raise_error(
          an_instance_of(Paramore::NilParameter).and having_attributes(
            message: a_string_including('`id`')
          )
        )
      end
    end

    context 'and non-nullable array type' do
      let(:params) { { ary: nil } }

      let(:field) do
        Paramore.field({
          ary: Paramore.field([Types::Int]),
        })
      end

      it 'raises error' do
        expect(Types::Int).not_to receive(:[])
        expect { subject }.to raise_error(
          an_instance_of(Paramore::NilParameter).and having_attributes(
            message: a_string_including('`ary`')
          )
        )
      end
    end

    context 'and non-nullable nested type' do
      let(:params) { { metadata: nil } }

      let(:field) do
        Paramore.field({
          metadata: Paramore.field({
            email: Paramore.field(Types::Text),
          }),
        })
      end

      it 'raises error' do
        expect(Types::Text).not_to receive(:[])
        expect { subject }.to raise_error(
          an_instance_of(Paramore::NilParameter).and having_attributes(
            message: a_string_including('`metadata`')
          )
        )
      end
    end
  end
end
