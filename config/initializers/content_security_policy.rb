# The same policy as the reference (NewErpPython api/security.py): own scripts and styles only, no frames.
# Turbo and the importmap need no outside address; a new one (font, script, API) must be added here first.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.script_src  :self
    policy.style_src   :self, :unsafe_inline
    policy.img_src     :self, :data, :https
    policy.font_src    :self, :data
    policy.connect_src :self
    policy.object_src  :none
    policy.base_uri    :self
    policy.form_action :self
    policy.frame_ancestors :none
  end

  # Importmap's inline script gets a nonce, so script-src needs no 'unsafe-inline'.
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
end
