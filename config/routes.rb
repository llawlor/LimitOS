Rails.application.routes.draw do
  root 'home#index'

  devise_for :users

  get '/account' => 'users#account'
  resources :users

  get '/install' => 'devices#install'

  resources :devices do
    member do
      post :send_message
      get :nodejs_script
      get :arduino_script
    end
    resources :pins
    resources :synchronizations
  end

  namespace :api do
    namespace :v1 do
      resources :devices do
        resources :registrations
      end
    end
  end

end
