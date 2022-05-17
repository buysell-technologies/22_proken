Rails.application.routes.draw do
  namespace :slack do
    post "/receive", to: "slack#create"
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
