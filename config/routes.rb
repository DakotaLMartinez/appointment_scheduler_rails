Rails.application.routes.draw do
  devise_for :doctors
  resources :appointments
  resources :doctors, except: [:new, :create, :edit, :update] do 
    resources :appointments, only: [:index, :new]
  end
  resources :patients do 
    resources :doctors, only: [:index]
    resources :appointments, only: [:index, :new]
  end
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  root to: 'patients#index', constraints: lambda { |request| request.env['warden'].user.class.name == 'User' }, as: "user_root"
  root to: 'doctor/appointments#index', constraints: lambda { |request| request.env['warden'].user.class.name == 'Doctor' }, as: "doctor_root"
  root 'patients#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :doctor do 
    resources :appointments
    resources :patients
  end
end
