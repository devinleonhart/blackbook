Rails.application.routes.draw do
  root to: 'universes#index'

  devise_for :users

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

  if Rails.env.production?
    get '404', :to => 'universes#index'
  end

end
