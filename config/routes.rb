Brimir::Application.routes.draw do

  resources :groups

  resources :templates

  devise_for :users, controllers: { omniauth_callbacks: 'omniauth' }

  resources :users do
    member do
      get :stats
      get :tickets
    end
  end

  resources :tickets, only: [:index, :show, :update, :new, :create] do
    member do
      post :ping
      put :closed
    end
  end

  namespace :tickets do
    resource :deleted, only: :destroy, controller: :deleted
  end

  resources :labelings, only: [:destroy, :create]

  resources :rules

  resources :labels, only: [:destroy, :update, :index]

  resources :replies, only: [:create, :new]

  get '/attachments/:id/:format' => 'attachments#show'
  resources :attachments, only: [:index, :new]

  resources :email_addresses, only: [:index, :create, :new, :destroy]

  root to: 'tickets#index'

  namespace :api do
    namespace :v1 do
      resources :tickets, only: [ :index, :show ]
      resources :sessions, only: [ :create ]
    end
  end

end
