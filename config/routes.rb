Rails.application.routes.draw do
  root 'home#index'

  devise_for :users
  resources :users

  resources :devices do
    collection do
      post :send_message
    end
  end

end
