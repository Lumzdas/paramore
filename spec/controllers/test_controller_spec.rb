RSpec.describe TestController, 'parameter typecasting', type: :controller do
  let(:params) do
    {
      test: {
        id: '2071',
        name: ' Cowboy  Bebop',
        nested: {
          email: 'seeyou@cow.boy ',
          deeper: {
            depths: ['0.0', '-15', '3000.1', nil]
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
          'depths' => [0.0, -15.0, 3000.1, nil]
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
            'depths' => ['0.0', '-15', '3000.1', '']
          }
        }
      )

      get :untyped, params: params
    end
  end

  context 'nil parameters reach the controller' do
    let(:params) { nil }

    it 'raises error' do
      expect { get :typed, params: params }.to raise_error(ActionController::ParameterMissing)
    end

    context 'and default is set' do
      it 'does not raise error' do
        expect(ParameterInspector).to receive(:for).with({})
        get :default, params: params
      end

      context 'and only the inner param is missing' do
        let(:params) { { test: { some: :param } } }

        it 'does not raise error and sets the default' do
          expect(ParameterInspector).to receive(:for).with({ 'id' => 1 })
          get :default, params: params, as: :json
        end
      end
    end
  end

  context 'wild hash' do
    let(:params) do
      {
        test: {
          wild: {
            a: '1',
            b: '2',
            c: '3',
          }
        }
      }
    end

    it 'permits and casts the params' do
      expect(ParameterInspector).to receive(:for).with(
        'wild' => {
          'a' => 1,
          'b' => 2,
          'c' => 3,
        }
      )

      get :wild, params: params
    end
  end
end
