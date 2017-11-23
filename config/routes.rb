Rails.application.routes.draw do
  get 'current_status', to: 'dashboard#current_status'
  get 'availability_history', to: 'dashboard#availability_history'
end
