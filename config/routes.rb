require 'resque/server'

Rails.application.routes.draw do
  get 'welcome/index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'welcome#index'

  resources :recharge_subscriptions, only: :create
  resources :recharge_orders, only: :create

  mount Resque::Server.new, :at => "/resque"
end
