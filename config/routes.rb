Rails.application.routes.draw do
  root 'home#index'

  devise_for :users

  get '/account' => 'users#account'
  resources :users

  resources :devices do
    member do
      post :send_message
      get :nodejs_script
    end
    resources :pins
  end

end
