RSpec.describe TestController, 'parameter typecasting', type: :controller do
  let(:params) do
    {
      test: {
        id: '2071',
        name: ' Cowboy  Bebop',
        nested: {
          email: 'seeyou@cow.boy ',
          deeper: {
            depths: ['0.0', '-15', '3000.1']
          }
        },
        unpermitted: 'param'
      }
    }
  end

  it 'typecasts parameters' do
    expect(ParameterInspector).to receive(:for).with(
      'id' => 2071,
      'name' => 'Cowboy  Bebop',
      'nested' => {
        'email' => 'seeyou@cow.boy',
        'deeper' => {
          'depths' => [0.0, -15.0, 3000.1]
        }
      }
    )

    get :typed, params: params
  end

  context 'untyped parameters' do
    it 'does not cast the parameters' do
      expect(ParameterInspector).to receive(:for).with(
        'id' => '2071',
        'name' => ' Cowboy  Bebop',
        'nested' => {
          'email' => 'seeyou@cow.boy ',
          'deeper' => {
            'depths' => ['0.0', '-15', '3000.1']
          }
        }
      )

      get :untyped, params: params
    end
  end
end
