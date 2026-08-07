# frozen_string_literal: true

module ImageHelper
  def generate_image_tag(image, size)
    return image_placeholder unless image&.image_file&.attached?

    if image.image_file.filename.extension.to_s.downcase == "gif"
      image_tag(safe_url_for(image.image_file), class: "img-thumbnail", loading: "lazy")
    else
      resize_params = resize_to_limit_for(size)
      variant = image.image_file.variant(resize_to_limit: resize_params)
      image_tag(safe_url_for(variant), class: "img-thumbnail", loading: "lazy")
    end
  rescue StandardError => error
    Rails.logger.error("Failed to render image #{image.id}: #{error.message}")
    image_placeholder(error: true)
  end

  private

  def resize_to_limit_for(size)
    case size
    when Integer
      [size, nil]
    when Array
      width = size[0] || 1000
      height = size[1]
      [width, height]
    else
      [1000, nil]
    end
  end

  def safe_url_for(attachment_or_variant)
    url_for(attachment_or_variant)
  rescue StandardError => error
    Rails.logger.warn("Failed to generate URL for attachment: #{error.message}")
    nil
  end

  def image_placeholder(error: false)
    content_tag(:div, error ? "Image unavailable" : "Loading...", class: "bb-image-placeholder")
  end
end
