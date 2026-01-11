Rails.application.routes.draw do
  # Health check endpoint for uptime monitoring
  get "up" => "rails/health#show", as: :rails_health_check

  root to: "universes#index"

  Rails.application.deprecators.silence do
    devise_for :users
  end

  namespace :admin do
    root to: "dashboard#index"
    get "dedupe/images", to: "dedupe#images", as: :dedupe_images
    post "dedupe/images/dedupe_group", to: "dedupe#dedupe_group", as: :dedupe_images_dedupe_group
    post "dedupe/images/dedupe_universe", to: "dedupe#dedupe_universe", as: :dedupe_images_dedupe_universe
  end

  namespace :api do
    namespace :discord_imports do
      post "/images", to: "images#create"
    end
  end

  resources :users

  resources :universes do
    resources :collaborations, except: [:update], shallow: true
    resources :characters, shallow: true do
      resources :character_tags, shallow: true
    end

    resources :images, except: [:index] do
      resources :image_tags, except: [:update], shallow: true
    end
  end

  # Random image from any universe the current user can access
  get "/random", to: "images#random", as: "random_image"

  # Favorites for the current user, grouped by universe
  get "/favorites", to: "favorites#index", as: "favorites"

  # Slideshow
  get "/slideshow", to: "slideshows#show", as: "slideshow"
  get "/slideshow/images", to: "slideshows#images", as: "slideshow_images"

  # Custom image routes for cleaner URLs
  get "/images/:id/:filename", to: "images#view", as: "view_image", constraints: { filename: /.*/ }

  get "404", to: "universes#index"
end
