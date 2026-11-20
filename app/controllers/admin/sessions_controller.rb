module Admin
  # Login page. The same rules as POST /auth/login: the throttle and Auth::Login.
  class SessionsController < BaseController
    allow_unauthenticated_access only: %i[new create]
    skip_after_action :verify_authorized # nobody is signed in yet, or the user only signs out

    def new; end

    def create
      throttle = LoginThrottle.new
      wait = throttle.retry_after(request.remote_ip, params[:username])
      if wait
        flash.now[:alert] = "Забагато невдалих спроб входу. Спробуйте знову через #{(wait / 60.0).ceil} хв."
        return render :new, status: :too_many_requests
      end

      result = Auth::Login.call(username: params[:username], password: params[:password])
      if result.success?
        throttle.succeeded(params[:username])
        start_session(result.value)
        redirect_to admin_root_path
      else
        throttle.failed(request.remote_ip, params[:username])
        flash.now[:alert] = result.error
        render :new, status: :unprocessable_content
      end
    end

    def destroy
      terminate_session
      redirect_to new_admin_session_path, status: :see_other
    end
  end
end
