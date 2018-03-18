require 'sidekiq/web'

Rails.application.routes.draw do
  get 'api/watchdoge/dashboard/current_status'
  get 'api/watchdoge/dashboard/availability_history'
  get 'api/watchdoge/dashboard/homepage_status'

  mount Sidekiq::Web => '/sidekiq'
end
