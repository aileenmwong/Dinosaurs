Rails.application.routes.draw do
  get 'dinos/index'

  get 'dinos/show'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'
  get '/welcome', to: 'welcome#index'
  resources :dinos
end
