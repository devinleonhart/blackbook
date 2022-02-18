# frozen_string_literal: true

module ImageHelper
  def generate_image_tag(image, size)
    if image.image_file.filename.extension == "gif"
      image_tag(url_for(image.image_file), class: "img-thumbnail")
    else
      image_tag(url_for(image.image_file.variant(resize_to_limit: size)), class: "img-thumbnail")
    end
  end
end
