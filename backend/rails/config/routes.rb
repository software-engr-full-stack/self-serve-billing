Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post '/sign_up', to: 'users#sign_up'
      post '/login', to: 'users#login'
      get '/verify', to: 'users#verify'
    end
  end
end
