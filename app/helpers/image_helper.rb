# frozen_string_literal: true

module ImageHelper
  def get_character_avatar_image(images)
    if images.present?
      image = images.find { |i| i.avatar == true }
      return images.first if image.nil?

      image
    end
  end

  def get_universe_avatar_image(images)
    images.find { |i| i.universe_avatar == true } if images.present?
  end

  def generate_image_tag(image, size)
    if image.image_file.filename.extension == "gif"
      image_tag(rails_storage_proxy_path(image.image_file), class: "img-thumbnail")
    else
      image_tag(rails_storage_proxy_path(image.image_file.variant(resize_to_limit: size)), class: "img-thumbnail")
    end
  end
end
