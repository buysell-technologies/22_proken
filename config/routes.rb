Rails.application.routes.draw do
  namespace :slack do
    post 'events', to: 'thank#respond'
  end
  post "/thank"=>"thank#create"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
