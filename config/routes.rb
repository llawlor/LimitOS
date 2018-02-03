Rails.application.routes.draw do
  root 'home#index'

  devise_for :users

  get '/account' => 'users#account'
  resources :users

  # temporary route to test install script
  get '/install' => 'devices#install'


  resources :devices do
    member do
      post :send_message
      get :nodejs_script
      get :arduino_script
      get :install
    end
    resources :pins
    resources :synchronizations
  end

end
