# frozen_string_literal: true

# Content Security Policy.
#
# Every asset this app loads is same-origin: JavaScript comes through importmap
# (locally pinned Hotwire + our own controllers) and CSS is the locally compiled
# Tailwind bundle. There are no CDNs, inline scripts, or inline event handlers,
# so the policy can be strict. The one inline element that remains — importmap's
# generated <script> (and Turbo's injected progress-bar <style>) — is allowed via
# a per-request nonce, which Turbo re-applies across navigations from csp_meta_tag.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src     :self
    policy.font_src        :self
    policy.img_src         :self, :data
    policy.object_src      :none
    policy.script_src      :self
    policy.style_src       :self
    policy.connect_src     :self
    policy.base_uri        :self
    policy.frame_ancestors :self
  end

  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]
end
