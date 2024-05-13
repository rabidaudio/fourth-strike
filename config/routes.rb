# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  get 'auth/:provider/callback', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :artists, :payees, :albums, :tracks

  scope path: '/products/:product_type/:product_id/splits' do
    get '/edit', to: 'splits#edit', as: 'edit_splits'
    post '/', to: 'splits#update', as: 'splits'
  end

  root 'static_pages#home'
end
