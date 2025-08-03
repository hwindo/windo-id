Rails.application.routes.draw do
  resources :posts
  resource :session
  resources :passwords, param: :token
  resources :posts
  get "/blog", to: "posts#index", as: :blog

  resources :tags, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]
  resources :categories, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

  # Filter Routes
  get "/posts/tagged/:tag", to: "posts#index", as: :posts_tagged
  get "/posts/categorized/:category", to: "posts#index", as: :posts_categorized

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # temporary
  get "/works", to: "home#index", as: :works
  get "/case-studies", to: "home#index", as: :case_studies

  # Defines the root path route ("/")
  root "home#index"
end
