require 'sidekiq/web'

Rails.application.routes.draw do
  scope 'api/watchdoge' do
    get 'dashboard/current_status'
    get 'dashboard/availability_history'
    get 'dashboard/homepage_status'
    get 'stats/jwt_usage', to: 'stats#jwt_usage'
    get 'stats/admin_jwt_usage/:jti', to: 'stats#admin_jwt_usage'
    get 'stats/last_30_days_usage'
  end

  mount Sidekiq::Web => '/sidekiq'
end
