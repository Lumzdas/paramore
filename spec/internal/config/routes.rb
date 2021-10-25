Rails.application.routes.draw do
  get '/test/typed', to: 'test#typed'
  get '/test/untyped', to: 'test#untyped'
  get '/test/default', to: 'test#default'
  get '/test/wild', to: 'test#wild'
  get '/test/almost_flat', to: 'test#almost_flat'
end
