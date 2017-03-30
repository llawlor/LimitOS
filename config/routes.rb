Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'home#index'

  resources :users
  
  resources :devices do
    collection do
      post :send_message
    end
  end

end
