# frozen_string_literal: true

module Api
  module DiscordImports
    class ImagesController < ApplicationController
      skip_before_action :authenticate_user!
      skip_before_action :verify_authenticity_token

      before_action :authenticate_discord_import!

      UNIVERSE_CODE_TO_NAME = {
        'KH' => 'Knighthood',
        'PS' => 'Pokemon',
        'ML' => 'Mobius Legends',
        'FF' => 'Final Fantasy',
        'MLP' => 'My Little Pony',
        'RPG' => 'Roleplaying Games'
      }.freeze

      def create
        universe_code = params[:universe_code].to_s.upcase
        file = params[:image_file]
        caption = params[:caption]

        universe_name = UNIVERSE_CODE_TO_NAME[universe_code]
        if universe_name.blank?
          render json: {
            error: 'universe_code is invalid',
            allowed_universe_codes: UNIVERSE_CODE_TO_NAME.keys
          }, status: :unprocessable_entity
          return
        end

        if file.blank?
          render json: { error: 'image_file is required' }, status: :unprocessable_entity
          return
        end

        universe = Universe.find_by(name: universe_name)
        if universe.nil?
          render json: { error: "Universe not found: #{universe_name}" }, status: :unprocessable_entity
          return
        end

        image = Image.new(universe: universe, caption: caption.to_s)
        image.image_file.attach(file)

        if image.save
          render json: { image_id: image.id }, status: :created
        else
          render json: { error: image.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
      end

      private

      def authenticate_discord_import!
        expected = ENV['DISCORD_IMPORT_TOKEN'].to_s
        if expected.empty?
          render json: { error: 'Server not configured (DISCORD_IMPORT_TOKEN missing)' }, status: :internal_server_error
          return
        end

        provided = bearer_token
        unless secure_compare(provided, expected)
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      def bearer_token
        header = request.headers['Authorization'].to_s
        return '' unless header.start_with?('Bearer ')

        header.delete_prefix('Bearer ').strip
      end

      def secure_compare(a, b)
        return false if a.blank? || b.blank?
        return false unless a.bytesize == b.bytesize

        ActiveSupport::SecurityUtils.secure_compare(a, b)
      end
    end
  end
end
