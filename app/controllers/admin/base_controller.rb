module Admin
  # Admin pages at /app. They use the same login cookie, roles and services as the JSON API; only the answer is
  # HTML (ERB + Turbo) instead of JSON. CSRF tokens protect the forms (ActionController::Base default).
  class BaseController < ApplicationController
    include Authentication
    include Pundit::Authorization

    layout "admin"

    after_action :verify_authorized
    helper_method :current_user, :allowed?

    rescue_from Pundit::NotAuthorizedError do
      render "admin/shared/forbidden", status: :forbidden
    end

    rescue_from ActiveRecord::RecordNotFound do
      render "admin/shared/not_found", status: :not_found
    end

    private

    def current_user = Current.user
    def pundit_user = Current.user

    # For the menu: each role sees only its modules.
    def allowed?(area) = Pundit.policy!(Current.user, area).manage?

    def request_authentication
      redirect_to new_admin_session_path
    end

    # A service result as a flash message: errors in red, warnings in yellow.
    def flash_result(result, notice:)
      if result.success?
        flash[:notice] = notice
        warnings = result.value.respond_to?(:warnings) ? result.value.warnings : Array(result.value)
        flash[:warning] = warnings.grep(String).join(" ") if warnings.grep(String).any?
      else
        flash[:alert] = result.error
      end
    end
  end
end
