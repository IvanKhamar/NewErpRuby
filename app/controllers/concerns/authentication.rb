# Cookie session for the API and the admin pages (the same login works for both), shaped like the concern the
# Rails 8 authentication generator writes. The session is an encrypted cookie with the user id, the security stamp
# of the account and the issue time. The stamp is compared with erp_user_login on every request, so a role or
# password change, or a disabled account, ends old sessions at once (see DECISIONS.md D6).
module Authentication
  extend ActiveSupport::Concern

  COOKIE = "newerp.auth".freeze
  LIFETIME = 8.hours

  included do
    before_action :require_authentication
  end

  class_methods do
    def allow_unauthenticated_access(**)
      skip_before_action(:require_authentication, **)
    end
  end

  private

  def authenticated? = resume_session.present?

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    Current.user ||= user_from_cookie
  end

  def user_from_cookie
    data = cookies.encrypted[COOKIE]
    return unless data.is_a?(Hash)

    user = User.active.includes(:login).find_by(user_id: data["user_id"])
    unless user&.login && ActiveSupport::SecurityUtils.secure_compare(user.security_stamp, data["stamp"].to_s)
      terminate_session
      return
    end

    # Sliding expiration: while the user works, the session is renewed after half of its lifetime.
    start_session(user) if Time.current.to_i - data["issued_at"].to_i > LIFETIME / 2
    user
  end

  def start_session(user)
    cookies.encrypted[COOKIE] = {
      value: { "user_id" => user.id, "stamp" => user.security_stamp, "issued_at" => Time.current.to_i },
      expires: LIFETIME.from_now,
      httponly: true,               # JavaScript on the page cannot read it
      same_site: :strict,           # other sites cannot send requests with it (CSRF)
      secure: Rails.env.production? # HTTPS only on a server
    }
    Current.user = user
  end

  def terminate_session
    cookies.delete(COOKIE, same_site: :strict)
    Current.user = nil
  end
end
