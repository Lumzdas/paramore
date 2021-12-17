RSpec.describe Paramore::CastParameters, '.run' do
  subject { described_class.run(field, params, no_extra_keys: no_extra_keys) }

  let(:no_extra_keys) { false }

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

  context 'with an array of hashes' do
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

  context 'with empty strings' do
    let(:params) { '' }
    let(:field) { Paramore.field(Types::Text) }

    it 'raises error' do
      expect(Types::Text).not_to receive(:[])
      expect { subject }.to raise_error(
        an_instance_of(Paramore::NilParameter).and having_attributes(
          message: a_string_including('Received a nil root field, but its type is non nullable!')
        )
      )
    end

    context 'and empty string are allowed' do
      let(:field) { Paramore.field(Types::Text, empty: true) }

      it 'preserves empty strings' do
        expect(subject).to eq('')
      end
    end

    context 'and nulls are allowed instead' do
      let(:field) { Paramore.field(Types::Text, null: true) }

      it 'preserves empty strings' do
        expect(subject).to eq(nil)
      end
    end

    context 'and a default is supplied instead' do
      let(:field) { Paramore.field(Types::Text, default: 'asd') }

      it 'preserves empty strings' do
        expect(subject).to eq('asd')
      end
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

    context 'and compact hash' do
      let(:field) do
        Paramore.field({
          id: Paramore.field(Types::Int, null: true),
          metadata: Paramore.field({
            email: Paramore.field(Types::Text, null: true),
          }, null: true),
        }, compact: true)
      end

      it 'reduces the hash' do
        expect(subject).to eq({})
      end
    end

    context 'and not required' do
      let(:field) do
        Paramore.field({
          id: Paramore.field(Types::Int, required: false),
          metadata: Paramore.field({
            email: Paramore.field(Types::Text, null: true),
          }, null: true),
        })
      end

      it 'does not keep keys' do
        expect(subject).to eq(
          {
            metadata: nil,
          },
        )
      end
    end

    context 'and default set' do
      let(:field) do
        Paramore.field({
          id: Paramore.field(Types::Text, default: 'antifault')
        })
      end

      it 'returns the default value' do
        expect(Types::Text).not_to receive(:[])

        expect(subject).to eq(id: 'antifault')
      end
    end

    context 'and lambda default set' do
      let(:field) do
        Paramore.field({
          id: Paramore.field(Types::Text, default: -> { described_class.to_s })
        })
      end

      it 'returns the default value' do
        expect(Types::Text).not_to receive(:[])

        expect(subject).to eq(id: 'Paramore::CastParameters')
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
            message: a_string_including('Received a nil `id`, but its type is non nullable!')
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
            message: a_string_including('Received a nil `ary`, but its type is non nullable!')
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
            message: a_string_including('Received a nil `metadata`, but its type is non nullable!')
          )
        )
      end
    end
  end

  context 'with a wild hash' do
    let(:params) do
      {
        a: 1,
        b: 2,
        c: 3,
      }
    end

    let(:field) do
      Paramore.field({
        Paramore::String => Paramore.field(Types::Int)
      })
    end

    it 'does not call any of the type classes' do
      expect(subject).to eq(
        {
          'a' => 1,
          'b' => 2,
          'c' => 3,
        },
      )
    end
  end

  context 'with no_extra_keys' do
    let(:no_extra_keys) { true }

    let(:params) do
      {
        id: '1',
        idz: '2',
      }
    end

    let(:field) do
      Paramore.field(id: Paramore.field(Types::Int))
    end

    it 'raises' do
      expect { subject }.to raise_error(
        an_instance_of(RuntimeError).and having_attributes(
          message: a_string_including('Found extra keys in root field: [:idz]!')
        )
      )
    end
  end

  context 'invalid input' do
    let(:params) do
      {
        id: '1.0',
      }
    end

    let(:field) do
      Paramore.field(id: Paramore.field(Types::Int))
    end

    it 'raises' do
      expect { subject }.to raise_error(
        an_instance_of(RuntimeError).and having_attributes(
          message: a_string_including('Tried casting `id`, but "1.0 is not an integer!" was raised!')
        )
      )
    end
  end

  context 'nested invalid input' do
    let(:params) do
      {
        a: {
          b: {
            c: '1.0',
          }
        },
      }
    end

    let(:field) do
      Paramore.field({
        a: Paramore.field({
          b: Paramore.field({
            c: Paramore.field(Types::Int),
          }),
        }),
      })
    end

    it 'raises' do
      expect { subject }.to raise_error(
        an_instance_of(RuntimeError).and having_attributes(
          message: a_string_including('Tried casting `a.b.c`, but "1.0 is not an integer!" was raised!')
        )
      )
    end
  end
end
