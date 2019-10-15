# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, constraints: { format: 'json' } do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth'

      # TODO: is this needed?
      #post '/auth/login', to: 'authentication#login'

      resources :universes do
        resources :locations, shallow: true
      end
    end
  end
end
