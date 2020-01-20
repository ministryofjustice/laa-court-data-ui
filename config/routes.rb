# frozen_string_literal: true

Rails.application.routes.draw do
  authenticated :user do
    root to: 'search_filters#new', as: :authenticated_root
  end

  devise_scope :user do
    unauthenticated :user do
      root to: 'users/sessions#new', as: :unauthenticated_root
    end
  end

  resources :search_filters, only: %i[new create]
  resources :searches, only: %i[new create]

  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    unlocks: 'users/unlocks'
  }

  get 'ping', to: 'status#ping', format: :json
end
