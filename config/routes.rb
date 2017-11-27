Rails.application.routes.draw do
  get 'dashboard/current_status'
  get 'dashboard/availability_history'
  get 'dashboard/homepage_status'
end
