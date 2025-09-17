Rails.application.routes.draw do
  root to: 'universes#index'

  devise_for :users

  resources :users

  resources :universes do
    resources :collaborations, except: [:update], shallow: true
    resources :characters, shallow: true

    resources :images, except: [:index] do
      resources :image_tags, except: [:update], shallow: true
    end

  end

  # Custom image routes for cleaner URLs
  get '/images/:id/:filename', to: 'images#view', as: 'view_image', constraints: { filename: /.*/ }

  get '404', :to => 'universes#index'

end
