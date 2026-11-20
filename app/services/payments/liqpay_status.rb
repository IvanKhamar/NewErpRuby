module Payments
  # Whether the order is paid through LiqPay. State is a number, like a .NET enum.
  class LiqpayStatus < ApplicationService
    NOT_FOUND = 0
    WAITING = 1
    PAID = 2
    FAILED = 3
    REVERSED = 4
    LABELS = { NOT_FOUND => "Ще не оплачено", WAITING => "Оплата в процесі", PAID => "Оплачено",
               FAILED => "Оплата не вдалася", REVERSED => "Гроші повернено" }.freeze

    State = Data.define(:state, :label, :amount, :paid_at, :test)

    def initialize(order_id:, client: Liqpay::Client.build)
      @order_id = order_id
      @client = client
    end

    def call
      return not_found("Замовлення #{@order_id} не знайдено.") unless Order.exists?(order_id: @order_id)

      reply = @client.status(@order_id)
      state = interpret(reply)
      success(State.new(state:, label: LABELS[state], amount: reply.amount,
                        paid_at: state == PAID ? reply.end_date : nil, test: @client.test?))
    rescue Liqpay::Client::Error => e
      failure(e.message)
    end

    private

    # wait_accept and wait_compensation already mean the money is taken.
    def interpret(reply)
      return NOT_FOUND if reply.error_code == "payment_not_found"
      return PAID if %w[success sandbox wait_accept wait_compensation].include?(reply.status)
      return REVERSED if reply.status == "reversed"
      return FAILED if %w[failure error].include?(reply.status)
      raise DomainError, "LiqPay відповів помилкою: #{reply.error_code}." if reply.status.nil? && reply.error_code

      WAITING
    end
  end
end
