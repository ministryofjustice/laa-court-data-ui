# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'search_filters#new'
  resources :search_filters, only: %i[new create]
  resources :searches, only: %i[new create]

  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    unlocks: 'users/unlocks'
  }
end
