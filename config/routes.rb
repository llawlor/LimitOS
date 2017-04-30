Rails.application.routes.draw do
  resources :pins
  root 'home#index'

  devise_for :users

  get '/account' => 'users#account'
  resources :users

  resources :devices do
    collection do
      post :send_message
    end
  end

end
