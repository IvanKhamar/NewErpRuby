module Api
  module V1
    # LiqPay links and status, PrivatBank payments (Admin, Manager).
    class PaymentsController < BaseController
      MAX_PAGE_SIZE = 100

      before_action -> { authorize :finance, :manage? }

      def liqpay_link
        amount = params[:amount].nil? ? nil : decimal_value(params[:amount], "amount")
        result = Payments::LiqpayLink.call(order_id: params[:id].to_i, amount:)
        return render_failure(result) unless result.success?

        render_json IntegrationSerializers::PaymentLink, result.value
      end

      def liqpay_status
        result = Payments::LiqpayStatus.call(order_id: params[:id].to_i)
        return render_failure(result) unless result.success?

        render_json IntegrationSerializers::LiqpayState, result.value
      end

      def bank
        page = [int_param(:page, default: 1), 1].max
        page_size = int_param(:pageSize, default: 50).clamp(1, MAX_PAGE_SIZE)
        payments = bank_filter(BankPayment.all)
        items = payments.includes(:order).newest_first.offset((page - 1) * page_size).limit(page_size)
        render json: PagedResultSerializer.new(items:, page:, page_size:, total_count: payments.count,
                                               item_serializer: IntegrationSerializers::BankPayment).serialize
      end

      def import_bank
        result = Payments::ImportBankStatement.call(from: date_param(:from), to: date_param(:to))
        return render_failure(result) unless result.success?

        s = result.value
        render json: { clientConfigured: s.client_configured, fetched: s.fetched, added: s.added, skipped: s.skipped }
      end

      private

      def bank_filter(payments)
        payments = payments.where(show_status: !bool_param(:hidden))
        payments = payments.where(trandate: date_param(:from)..) if params[:from].present?
        payments = payments.where(trandate: ..date_param(:to)) if params[:to].present?
        payments = payments.where(order_id: int_param(:orderId)) if params[:orderId].present?
        unless params[:linked].nil?
          payments = bool_param(:linked) ? payments.where.not(order_id: 0) : payments.where(order_id: 0)
        end
        if params[:search].present?
          like = "%#{BankPayment.sanitize_sql_like(params[:search].to_s.strip)}%"
          payments = payments.where("description LIKE :q OR terminal LIKE :q OR amount LIKE :q", q: like)
        end
        payments
      end
    end
  end
end
