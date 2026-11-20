module Api
  module V1
    # Refunds with a recipient check (a new module, not in the reference contract): Admin and Manager.
    class RefundsController < BaseController
      before_action -> { authorize :finance, :manage? }

      # POST /refunds/recipient-checks {iban, name, orderId?}
      def check_recipient
        p = params.permit(:iban, :name, :orderId)
        order_id = p[:orderId].nil? ? nil : integer_value(p[:orderId], "orderId")
        result = Refunds::CheckRecipient.call(iban: p[:iban], name: p[:name], order_id:, user: Current.user)
        return render_failure(result) unless result.success?

        render json: check_json(result.value.check).merge(message: result.value.message), status: :created
      end

      # GET /refunds/recipient-checks?orderId= — the audit log, newest first.
      def checks
        checks = RefundRecipientCheck.newest_first.limit(200)
        checks = checks.where(order_id: int_param(:orderId)) if params[:orderId].present?
        render json: checks.map { |check| check_json(check) }
      end

      # POST /refunds {orderId, recipientCheckId, amount, confirmCloseMatch}
      def create
        p = params.permit(:orderId, :recipientCheckId, :amount, :confirmCloseMatch)
        result = Refunds::Create.call(order_id: integer_value(p[:orderId], "orderId"),
                                      check_id: integer_value(p[:recipientCheckId], "recipientCheckId"),
                                      amount: decimal_value(p[:amount], "amount"),
                                      confirm_close_match: p[:confirmCloseMatch] == true, user: Current.user)
        return render_failure(result) unless result.success?

        refund = result.value
        render json: { id: refund.id, orderId: refund.order_id, recipientCheckId: refund.recipient_check_id,
                       iban: Iban.new(refund.iban).formatted, recipientName: refund.recipient_name,
                       amount: refund.amount.to_f, confirmedCloseMatch: refund.confirmed_close_match }, status: :created
      end

      private

      def check_json(check)
        { id: check.id, orderId: check.order_id, iban: Iban.new(check.iban).formatted, name: check.entered_name,
          result: check.result, suggestedName: check.suggested_name, score: check.score&.to_f,
          userId: check.user_id, checkedAt: check.created_at.strftime("%Y-%m-%dT%H:%M:%S") }
      end
    end
  end
end
