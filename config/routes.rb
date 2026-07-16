Rails.application.routes.draw do
  get "/api-docs/api-docs", to: redirect("/index.html")

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  post "register", to: "auth#register_user"
  post "login", to: "auth#login_user"

  post "admin/register", to: "auth#register_admin"
  post "admin/login", to: "auth#login_admin"

  get "/genres", to: "games#genres"
  get "/platforms", to: "games#platforms"

  resources :categories, only: [ :index, :create, :update, :destroy ]
  resources :favorites, only: [ :index, :create, :update, :destroy ]
  resources :games, only: [ :index, :show ]
end
