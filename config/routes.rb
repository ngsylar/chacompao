Rails.application.routes.draw do
  resources :favorites
  resources :versions
  resources :songs

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get 'home/index', as: 'homepage'
  devise_for :users
  devise_scope :user do
    authenticated :user do
      root 'home#index', as: :authenticated_root
    end
  
    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end
end
