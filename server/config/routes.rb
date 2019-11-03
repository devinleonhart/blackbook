# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, constraints: { format: 'json' } do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth'

      # TODO: is this needed?
      #post '/auth/login', to: 'authentication#login'

      resources :universes do
        resources :locations, shallow: true
        resources :characters, shallow: true do
          resources :character_items, shallow: true
          resources :character_traits, shallow: true
          resources :mutual_relationships, shallow: true
        end

        get 'search', to: 'search#multisearch', as: :search
      end

      resources :images, except: [:index] do
        resources :image_tags, except: [:update], shallow: true
      end
    end
  end
end
