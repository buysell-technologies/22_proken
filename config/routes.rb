Rails.application.routes.draw do
  post 'events', to: 'slack#create'
  post 'actions', to: 'slack#action'
  get 'home/index'
  root to: 'home#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
