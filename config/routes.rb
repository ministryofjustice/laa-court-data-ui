Rails.application.routes.draw do
  root to: 'search#new'

  get 'search', action: :new, controller: :search
  post 'search', action: :create, controller: :search
end
