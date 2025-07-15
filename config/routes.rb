# frozen_string_literal: true

Rails.application.routes.draw do
  authenticated :user do
    root to: 'search_filters#new', as: :authenticated_root
  end

  authenticated :user, ->(u) { u.admin? } do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_scope :user do
    get '/update_cookies', to: 'users/sessions#update_cookies'

    unauthenticated :user do
      root to: 'users/sessions#new', as: :unauthenticated_root
    end
  end

  resources :search_filters, only: %i[new create]
  resources :searches, only: %i[new create] do
    get :create, on: :collection
  end

  resources :prosecution_cases, only: %i[show]
  resources :defendants, only: %i[edit update]
  resources :laa_references, only: %i[new create]
  resources :hearings, only: %i[show]
  resources :court_applications, only: %i[show] do
    resource :subject, only: %i[show] do
      member do
        post :link
        post :unlink
      end
    end
    resources :hearings, only: [] do
      resources :hearing_days, only: %i[show]
    end
  end

  devise_for :users, controllers: {
    passwords: 'users/passwords',
    sessions: 'users/sessions',
    unlocks: 'users/unlocks'
  }

  resources :users, only: %i[index show new create edit update destroy] do
    get 'change_password', on: :member
    patch 'update_password', on: :member
    post 'search', on: :collection
    get 'search', on: :collection
  end

  resources :hearing_repull_batches, only: %i[new create show]

  post '/cookies/settings', to: 'cookies#create'
  get '/cookies/settings', to: 'cookies#new'
  get '/cookies', to: 'cookies#cookie_details'

  get 'ping', to: 'status#ping', format: :json

  get 'users/export/all', to: 'users#export', defaults: { format: :csv }

  get '/401', to: 'errors#unauthorized', as: 'unauthorized_error'
  get '/404', to: 'errors#not_found', as: 'not_found_error'
  get '/422', to: 'errors#unacceptable', as: 'unacceptable_error'
  get '/500', to: 'errors#internal_error', as: 'internal_error'

  # catch-all route
  # -------------------------------------------------
  # WARNING: do not put routes below this point
  match '*path', to: 'errors#not_found', via: :all unless Rails.env.development?
end
