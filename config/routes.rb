# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'search_filters#new'
  resources :search_filters, only: [:new, :create]
  resources :searches, only: [:new, :create]
end
