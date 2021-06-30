RSpec.describe Paramore::PermittedParameterArgument, '.parse' do
  subject { described_class.parse(types_definition) }

  let(:types_definition) do
    {
      id: Paratype[Types::Int],
      name: Paratype[Types::Text],
      metadata: Paratype[{
        email: Paratype[Types::Text],
        tags: Paratype[[Types::Int]],
        deeper: {
          depth: Paratype[Types::Int],
        },
      }],
      extra: Paratype[{
        parameter: Paratype[Types::Int]
      }],
    }
  end

  it "returns an array that rails' .permit expects" do
    expect(subject).to eq(
      [:id, :name, metadata: [:email, tags: [], deeper: [:depth]], extra: [:parameter]]
    )
  end
end
