Rails.application.routes.draw do
  namespace :admin do
    resources :users
    resources :devices
    resources :pins
    resources :registrations
    resources :synchronizations

    root to: "users#index"
  end

  root 'home#index'

  devise_for :users

  # for the status page
  get '/status' => 'home#status'

  # frequently asked questions
  get '/faq' => 'home#faq'

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
      post :install
      get :setup
    end
    collection do
      get :pretty_print_install
    end
    resources :pins
    resources :synchronizations
  end

  resources :docs do
    collection do
      get 'installation'
      get 'pins'
      get 'i2c'
      get 'security'
      get 'api'
      get 'live_video'
    end
  end

  resources :tutorials do
    collection do
      get 'led'
      get 'button'
      get 'active_buzzer'
      get 'live_video'
    end
  end

  namespace :api do
    namespace :v1 do
      resources :devices do
        member do
          post :nodejs_script
          post :control
        end
        collection do
          get :install_script_info
        end
        resources :registrations
      end
    end
  end

end
