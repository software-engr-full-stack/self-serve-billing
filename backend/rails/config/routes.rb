Rails.application.routes.draw do
  # resources :users

  namespace :api do
    namespace :v1 do
      resources :users
      post '/login', to: 'auth#create'
      get '/current_user', to: 'auth#show'
      post '/sign_up', to: 'users#create'
    end
  end
end
