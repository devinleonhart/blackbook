# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "universes#index"

  devise_for :users

  resources :users, only: [:show, :update]

  resources :universes do
    resources :locations, shallow: true
    resources :characters, shallow: true do
      resources :character_items, shallow: true
      resources :character_traits, shallow: true
      resources :mutual_relationships, shallow: true
    end

    resources :images, except: [:index] do
      resources :image_tags, except: [:update], shallow: true
    end

    get 'search', to: 'search#multisearch', as: :search
  end

end
