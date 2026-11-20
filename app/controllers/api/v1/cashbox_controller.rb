module Api
  module V1
    # Fiscal receipts through Checkbox (Admin, Manager).
    class CashboxController < BaseController
      before_action -> { authorize :finance, :manage? }

      def fiscalize
        result = Cashbox::Fiscalize.call(cheque_id: params[:id].to_i)
        return render_failure(result) unless result.success?

        render_json IntegrationSerializers::Cheque, result.value
      end
    end
  end
end
