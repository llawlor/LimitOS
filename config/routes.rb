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

  # run limitos scripts on a linux box
  get '/run' => 'devices#run'

  # register a device and take ownership of it
  get '/register' => 'devices#register'
  post '/submit_registration' => 'devices#submit_registration', as: :submit_registration

  # control a device
  get '/control/:slug' => 'control#show'
  get '/drive/:slug' => 'control#show'

  # embed a device in another webpage
  get '/embed/:slug' => 'devices#embed'

  # edit the control page
  get '/control/:slug/edit' => 'control#edit'
  # update the control page
  patch '/control/:slug/update' => 'control#update'

  resources :devices do
    member do
      get :arduino_script
      get :nodejs_script
      get :setup
      post :run
      post :send_message
    end
    collection do
      get :pretty_print_install
    end
    resources :pins
    resources :synchronizations
  end

  resources :docs do
    collection do
      get 'activation'
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
      get 'rover'
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
