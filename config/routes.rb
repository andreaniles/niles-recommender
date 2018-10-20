Rails.application.routes.draw do
  root to: 'application#index'

  resources :application

  get 'api/scenarios'
end
