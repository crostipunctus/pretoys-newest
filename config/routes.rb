Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ]
  resource :verification, only: %i[ new create ]
  resource :profile, only: %i[ edit update ]

  resources :listings do
    get :mine, on: :collection
    patch :mark, on: :member
  end

  resources :members, only: %i[ index show ]
  resources :invites, only: %i[ new create show ]

  namespace :admin do
    resource :import, only: %i[ new create ] do
      post :preview
    end
    resources :members, only: :destroy
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "listings#index"
end
