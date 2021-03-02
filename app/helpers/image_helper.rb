# frozen_string_literal: true

module ImageHelper
  def get_avatar_image(images)
    if images.present?
      image = images.find { |i| i.avatar == true }
      return images.first if image.nil?

      image
    end
  end
end
