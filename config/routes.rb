Rails.application.routes.draw do
  namespace :slack do
    post 'events', to: 'tank#respond'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
