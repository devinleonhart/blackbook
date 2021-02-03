# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  root to: "universes#index"

  resources :users, only: [:show, :update]

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
