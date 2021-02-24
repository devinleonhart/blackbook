module ImageHelper
  def get_avatar_image(images)
    unless images.nil?
      unless images.empty?
        image = images.find { | image | image.avatar == true }
        if image == nil
          return images.first
        end
        return image
      end
    end
  end
end
