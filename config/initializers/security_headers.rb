# Headers every response gets (SecurityHeaders in the .NET version, api/security.py in the Python one).
Rails.application.config.action_dispatch.default_headers.merge!(
  "X-Content-Type-Options" => "nosniff",
  "X-Frame-Options" => "DENY",
  "Referrer-Policy" => "no-referrer",
  "Permissions-Policy" => "camera=(), microphone=(), geolocation=(), payment=()",
  "Cross-Origin-Opener-Policy" => "same-origin"
)
