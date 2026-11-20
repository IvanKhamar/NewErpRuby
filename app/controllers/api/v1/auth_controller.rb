module Api
  module V1
    # Login with a cookie session (the same cookie works on the admin pages).
    class AuthController < BaseController
      allow_unauthenticated_access only: :login
      # Anonymous on purpose: there is no user yet to authorize.
      skip_after_action :verify_authorized, only: :login
      before_action -> { authorize :account, :manage? }, except: :login

      def login
        username = login_params[:username]
        throttle = LoginThrottle.new
        # Behind a reverse proxy request.remote_ip needs config.action_dispatch.trusted_proxies (see README).
        wait = throttle.retry_after(request.remote_ip, username)
        return too_many_tries(wait) if wait

        result = Auth::Login.call(username:, password: login_params[:password])
        unless result.success?
          throttle.failed(request.remote_ip, username)
          return render_problem(401, "Невірний логін або пароль")
        end

        throttle.succeeded(username)
        start_session(result.value)
        render_json CurrentUserSerializer, result.value
      end

      def logout
        terminate_session
        head :no_content
      end

      def me
        render_json CurrentUserSerializer, Current.user
      end

      def change_password
        result = Auth::ChangePassword.call(user: Current.user, current_password: password_params[:currentPassword],
                                           new_password: password_params[:newPassword])
        return render_failure(result) unless result.success?

        # The new stamp ended every session, this one included, so it is issued again.
        start_session(result.value.reload)
        head :no_content
      end

      private

      def login_params = params.permit(:username, :password)
      def password_params = params.permit(:currentPassword, :newPassword)

      def too_many_tries(wait)
        minutes = (wait / 60.0).ceil
        render_problem(429, "Забагато невдалих спроб входу",
                       "Забагато невдалих спроб входу. Спробуйте знову через #{minutes} хв.",
                       headers: { "Retry-After" => wait.ceil.to_s })
      end
    end
  end
end
