Rails.application.routes.draw do
  root to: 'universes#index'

  devise_for :users

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
  get '/random', to: 'images#random', as: 'random_image'

  # Favorites for the current user, grouped by universe
  get '/favorites', to: 'favorites#index', as: 'favorites'

  # Custom image routes for cleaner URLs
  get '/images/:id/:filename', to: 'images#view', as: 'view_image', constraints: { filename: /.*/ }

  get '404', :to => 'universes#index'

end
