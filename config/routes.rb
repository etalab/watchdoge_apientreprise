require 'sidekiq/web'

Rails.application.routes.draw do
  scope 'api/watchdoge' do
    get 'dashboard/current_status'
    get 'dashboard/availability_history'
    get 'dashboard/homepage_status'
    get 'stats/jwt_usage/:jwt', to: 'stats#jwt_usage', jwt: /([a-zA-Z0-9_-]+\.){2}([a-zA-Z0-9_-]+)/ # routing does not work without the regexp, jwt has two '.'
    get 'stats/last_30_days_usage'
  end

  mount Sidekiq::Web => '/sidekiq'
end
