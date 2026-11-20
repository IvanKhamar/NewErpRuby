module Api
  module V1
    # Liveness for Docker and load balancers. Anonymous on purpose: it serves no data.
    class HealthController < BaseController
      allow_unauthenticated_access
      skip_after_action :verify_authorized

      def show
        render plain: "Healthy" # the same answer as MapHealthChecks in the .NET version
      end
    end
  end
end
