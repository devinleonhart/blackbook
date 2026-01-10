# frozen_string_literal: true

module ImageHelper
  PLACEHOLDER_STYLE =
    "display: flex; align-items: center; justify-content: center; " \
    "background-color: #f8f9fa; border: 1px dashed #dee2e6; " \
    "min-height: 200px; color: #6c757d;"

  def generate_image_tag(image, size)
    return image_placeholder unless image&.image_file&.attached?

    if image.image_file.filename.extension.to_s.downcase == "gif"
      image_tag(
        safe_url_for(image.image_file),
        class: "img-thumbnail",
        loading: "lazy",
        data: { reloadable_image: true },
      )
    else
      resize_params = resize_to_limit_for(size)
      variant = image.image_file.variant(resize_to_limit: resize_params)
      image_tag(
        safe_url_for(variant),
        class: "img-thumbnail",
        loading: "lazy",
        data: { reloadable_image: true },
      )
    end
  rescue StandardError => error
    Rails.logger.error("Failed to generate image tag for image #{image.id}: #{error.message}")
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

    blob = extract_blob(attachment_or_variant)
    fallback_url_for_blob(blob) if blob
  end

  def extract_blob(attachment_or_variant)
    return attachment_or_variant.blob if attachment_or_variant.respond_to?(:blob)

    if attachment_or_variant.respond_to?(:image) && attachment_or_variant.image.respond_to?(:blob)
      return attachment_or_variant.image.blob
    end

    nil
  end

  def fallback_url_for_blob(_blob)
    # No fallback URL available for local storage
    nil
  end

  def image_placeholder(error: false)
    placeholder_class = error ? "img-thumbnail placeholder-error" : "img-thumbnail placeholder"
    placeholder_text = error ? "Image unavailable" : "Loading..."

    content_tag(
      :div,
      placeholder_text,
      class: placeholder_class,
      style: PLACEHOLDER_STYLE,
    )
  end
end
