Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to:'application#root'
  scope '/:locale' do
    get '/play', to: 'games#welcome'
    get '/about', to: 'pages#about'
    get '/download', to: 'pages#download'
  end
  mount ActionCable.server => '/cable'
end
