# frozen_string_literal: true

# Application-wide Permissions Policy: disable browser features the app never
# uses. Fullscreen is allowed for same-origin so the slideshow's fullscreen
# button keeps working.
Rails.application.configure do
  config.permissions_policy do |policy|
    policy.camera      :none
    policy.gyroscope   :none
    policy.microphone  :none
    policy.usb         :none
    policy.geolocation :none
    policy.payment     :none
    policy.fullscreen  :self
  end
end
