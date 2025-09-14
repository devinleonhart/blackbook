# frozen_string_literal: true

module ImageHelper
  def generate_image_tag(image, size)
    return image_placeholder if !image&.image_file&.attached?

    begin
      if image.image_file.filename.extension == "gif"
        image_tag(safe_url_for(image.image_file), class: "img-thumbnail", loading: "lazy")
      else
        image_tag(safe_url_for(image.image_file.variant(resize_to_limit: size)), class: "img-thumbnail", loading: "lazy")
      end
    rescue => e
      Rails.logger.error("Failed to generate image tag for image #{image.id}: #{e.message}")
      image_placeholder(error: true)
    end
  end

  private

  def safe_url_for(attachment_or_variant)
    begin
      url_for(attachment_or_variant)
    rescue => e
      Rails.logger.warn("Failed to generate URL for attachment: #{e.message}")

      # Try to get the blob key and construct a fallback URL
      if attachment_or_variant.respond_to?(:blob)
        blob = attachment_or_variant.blob
        fallback_url_for_blob(blob)
      else
        # This might be a variant
        blob = attachment_or_variant.blob if attachment_or_variant.respond_to?(:blob)
        blob ||= attachment_or_variant.image.blob if attachment_or_variant.respond_to?(:image)
        fallback_url_for_blob(blob) if blob
      end
    end
  end

  def fallback_url_for_blob(blob)
    return nil unless blob

    # Construct DigitalOcean Spaces URL directly as fallback
    if Rails.env.production?
      endpoint = Rails.application.credentials.dig(:digitalocean, :endpoint)
      bucket = Rails.application.credentials.dig(:digitalocean, :bucket)

      if endpoint && bucket
        "#{endpoint}/#{bucket}/#{blob.key}"
      end
    end
  rescue => e
    Rails.logger.error("Failed to generate fallback URL: #{e.message}")
    nil
  end

  def image_placeholder(error: false)
    placeholder_class = error ? "img-thumbnail placeholder-error" : "img-thumbnail placeholder"
    placeholder_text = error ? "Image unavailable" : "Loading..."

    content_tag(:div, placeholder_text, class: placeholder_class, style: "display: flex; align-items: center; justify-content: center; background-color: #f8f9fa; border: 1px dashed #dee2e6; min-height: 200px; color: #6c757d;")
  end
end
