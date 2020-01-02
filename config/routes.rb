Rails.application.routes.draw do
  root to: 'search#new'
  match '/search', to: 'search#new', via: [:get]
  match '/search', to: 'search#create', via: [:post]
end
