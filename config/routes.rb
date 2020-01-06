# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'search#new'
  get 'search/new', action: :new, controller: :search
  post 'search/new', action: :create, controller: :search

  get 'search', action: :index, controller: :search
  post 'search', action: :index, controller: :search
end
