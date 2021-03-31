require 'resque/server'

Rails.application.routes.draw do
  get 'welcome/index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'welcome#index'

  resource :shopify_cache, only: [] do
    collection do
      get :refresh_all
    end
  end

  resources :recharge_subscriptions, only: :index
  resources :recharge_orders, only: :index

  resources :selection_sets, only: [:index, :new, :create, :show]
  resources :size_breaks, only: [:index]

  mount Resque::Server.new, :at => "/resque"
end
