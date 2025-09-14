Rails.application.routes.draw do
  root to: 'universes#index'

  devise_for :users

  resources :users

  resources :universes do
    resources :collaborations, except: [:update], shallow: true
    resources :characters, shallow: true do
      resources :mutual_relationships, shallow: true
    end

    resources :images, except: [:index] do
      resources :image_tags, except: [:update], shallow: true
    end

    get 'search', to: 'search#multisearch', as: :search
  end

  # Admin routes (production only)
  if Rails.env.production?
    namespace :admin do
      resources :image_migration, only: [:index] do
        collection do
          get :status
          get :missing_images
        end
      end
    end

    get '404', :to => 'universes#index'
  end

end
