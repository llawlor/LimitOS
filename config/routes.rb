Rails.application.routes.draw do
  root 'home#index'

  devise_for :users

  get '/account' => 'users#account'
  resources :users

  # install limitos scripts onto a linux box
  get '/install' => 'devices#install'

  # register a device and take ownership of it
  get '/register' => 'devices#register'
  post '/submit_registration' => 'devices#submit_registration', as: :submit_registration

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
        member do
          post :nodejs_script
        end
        resources :registrations
      end
    end
  end

end
