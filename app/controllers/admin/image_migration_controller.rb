# frozen_string_literal: true

# Admin controller for monitoring image migration status
# Only accessible in production to authorized users
class Admin::ImageMigrationController < ApplicationController
  before_action :ensure_admin_access
  before_action :ensure_production_environment

  def index
    @migration_stats = calculate_migration_stats
    @recent_images = Image.includes(image_file_attachment: :blob)
                         .order(created_at: :desc)
                         .limit(10)
                         .map { |img| [img, img.storage_status] }
  end

  def status
    render json: calculate_migration_stats
  end

  def missing_images
    @missing_images = []

    Image.includes(image_file_attachment: :blob).find_each(batch_size: 50) do |image|
      status = image.storage_status
      @missing_images << { image: image, status: status } unless status[:local]
    end

    respond_to do |format|
      format.html
      format.json { render json: @missing_images.map { |item| item[:image].as_json.merge(storage_status: item[:status]) } }
    end
  end

  private

  def ensure_admin_access
    # Add your admin authentication logic here
    # For example:
    # redirect_to root_path unless current_user&.admin?

    # For now, just check if user is signed in
    redirect_to new_user_session_path unless user_signed_in?
  end

  def ensure_production_environment
    redirect_to root_path unless Rails.env.production?
  end

  def calculate_migration_stats
    total_images = Image.joins(:image_file_attachment).count
    return { total: 0, local: 0, cloud: 0, both: 0, neither: 0 } if total_images == 0

    stats = { total: total_images, local: 0, cloud: 0, both: 0, neither: 0, errors: 0 }

    Image.includes(image_file_attachment: :blob).find_each(batch_size: 50) do |image|
      begin
        status = image.storage_status

        if status[:local] && status[:cloud]
          stats[:both] += 1
        elsif status[:local]
          stats[:local] += 1
        elsif status[:cloud]
          stats[:cloud] += 1
        else
          stats[:neither] += 1
        end
      rescue => e
        stats[:errors] += 1
        Rails.logger.error("Error checking image #{image.id}: #{e.message}")
      end
    end

    stats[:migration_progress] = ((stats[:local] + stats[:both]).to_f / total_images * 100).round(1)
    stats
  end
end
