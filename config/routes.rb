require 'sidekiq/web'

Rails.application.routes.draw do
  scope 'api/watchdoge' do
    get 'dashboard/current_status'
    get 'dashboard/availability_history'
    get 'dashboard/homepage_status'
  end

  mount Sidekiq::Web => '/sidekiq'
end
