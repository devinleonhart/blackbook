# frozen_string_literal: true

# Content Security Policy.
#
# Every asset this app loads is same-origin: JavaScript comes through importmap
# (locally pinned Hotwire + our own controllers) and CSS is the locally compiled
# Tailwind bundle. There are no CDNs, inline scripts, or inline event handlers,
# so the policy can be strict. The one inline element that remains — importmap's
# generated <script> (and Turbo's injected progress-bar <style>) — is allowed via
# a nonce.
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

  # The nonce MUST be stable per session, not per request. On a Turbo Drive
  # navigation the browser keeps enforcing the ORIGINAL document's CSP header
  # while Turbo re-evaluates the fetched page's inline importmap <script>; a
  # fresh random nonce each request would no longer match and the script would
  # be blocked (CSP script-src-elem violation). One nonce per session keeps
  # every page's scripts matching the enforced header.
  config.content_security_policy_nonce_generator = lambda do |request|
    request.session[:csp_nonce] ||= SecureRandom.base64(16)
  end
  config.content_security_policy_nonce_directives = %w[script-src style-src]
end
