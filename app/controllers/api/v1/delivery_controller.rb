module Api
  module V1
    # Delivery: the waybill tracking refresh (Admin, Manager).
    class DeliveryController < BaseController
      before_action -> { authorize :orders, :manage? }

      def refresh_tracking
        summary = Delivery::RefreshTracking.call.value
        render json: { clientConfigured: summary.client_configured, checked: summary.checked, updated: summary.updated }
      end
    end
  end
end
