Rails.application.routes.draw do
  get '/test/typed', to: 'test#typed'
  get '/test/untyped', to: 'test#untyped'
end