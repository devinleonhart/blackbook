# frozen_string_literal: true

FactoryBot.define do
  factory :image_favorite do
    user
    image
  end
end
