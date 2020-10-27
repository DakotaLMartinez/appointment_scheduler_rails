Rails.application.routes.draw do
  resources :doctors
  resources :patients
  devise_for :users
  root 'patients#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
