# frozen_string_literal: true

module Api
  module DiscordImports
    class ImagesController < ApplicationController
      skip_before_action :authenticate_user!
      skip_before_action :verify_authenticity_token

      before_action :authenticate_discord_import!

      UNIVERSE_CODE_TO_NAME = {
        "KH" => "Knighthood",
        "PS" => "Pokemon",
        "ML" => "Mobius Legends",
        "FF" => "Final Fantasy",
        "MLP" => "My Little Pony",
        "RPG" => "Roleplaying Games",
      }.freeze

      def create
        universe_code = params[:universe_code].to_s.upcase
        file = params[:image_file]
        caption = params[:caption]

        universe_name = UNIVERSE_CODE_TO_NAME[universe_code]
        if universe_name.blank?
          render json: {
            error: "universe_code is invalid",
            allowed_universe_codes: UNIVERSE_CODE_TO_NAME.keys,
          }, status: :unprocessable_content
          return
        end

        if file.blank?
          render json: { error: "image_file is required" }, status: :unprocessable_content
          return
        end

        universe = Universe.find_by(name: universe_name)
        if universe.nil?
          render json: { error: "Universe not found: #{universe_name}" }, status: :unprocessable_content
          return
        end

        image = Image.new(universe: universe, caption: caption.to_s)
        image.image_file.attach(file)

        if image.save
          render json: { image_id: image.id }, status: :created
        else
          render json: { error: image.errors.full_messages.join(", ") }, status: :unprocessable_content
        end
      end

      private

      def authenticate_discord_import!
        expected = ENV["DISCORD_IMPORT_TOKEN"].to_s
        if expected.empty?
          render json: { error: "Server not configured (DISCORD_IMPORT_TOKEN missing)" }, status: :internal_server_error
          return
        end

        provided = bearer_token
        render json: { error: "Unauthorized" }, status: :unauthorized unless secure_compare(provided, expected)
      end

      def bearer_token
        header = request.headers["Authorization"].to_s
        return "" unless header.start_with?("Bearer ")

        header.delete_prefix("Bearer ").strip
      end

      def secure_compare(left, right)
        return false if left.blank? || right.blank?
        return false unless left.bytesize == right.bytesize

        ActiveSupport::SecurityUtils.secure_compare(left, right)
      end
    end
  end
end
