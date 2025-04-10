# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  get 'auth/:provider/callback', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  post '/albums/bandcamp_details', to: 'albums#extract_bandcamp_details', as: 'extract_bandcamp_details'

  resources :artists, :payees, :albums, :tracks
  
  resources :merch_orders, path: '/merch/orders'
  put '/merch/orders/:id/refund', to: 'merch_orders#refund', as: 'refund_merch_order'
  resources :merch_fulfillments, path: '/merch/orders/fulfillments'

  resources :iam8bit_sales, path: 'merch/iam8bit'
  resources :merch
  resources :rendered_services, path: 'services_rendered'

  get '/reports', to: 'reports#index'
  get '/reports/projects', to: 'reports#projects'
  get '/reports/generate', to: 'reports#combined_excel_report', as: 'reports_generate'
  get '/reports/:id/download', to: 'reports#download', as: 'reports_download'
  get '/issues', to: 'reports#needs_attention'

  scope path: '/products/:product_type/:product_id/splits' do
    get '/edit', to: 'splits#edit', as: 'edit_splits'
    post '/', to: 'splits#update', as: 'splits'

    post '/append', to: 'splits#append', as: 'append_split'
  end

  get '/imports', to: 'imports#index', as: 'imports'
  post '/imports/distrokid', to: 'imports#import_distrokid_streams'
  post '/imports/bandcamp', to: 'imports#import_bandcamp_sales'

  match '/internal/jobs' => DelayedJobWeb, :anchor => false, :via => [:get, :post], as: 'delayed_jobs'

  get '/privacy', to: 'static_pages#privacy'
  root 'static_pages#home'
end
