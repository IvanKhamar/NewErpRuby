module Payments
  # A LiqPay checkout link for an order. Without an amount it is the whole order; a part is fine (an advance), more
  # than the order is not.
  class LiqpayLink < ApplicationService
    Link = Data.define(:url, :amount, :currency, :test)

    def initialize(order_id:, amount:, client: Liqpay::Client.build)
      @order_id = order_id
      @amount = amount
      @client = client
    end

    def call
      order = Order.find_by(order_id: @order_id)
      return not_found("Замовлення #{@order_id} не знайдено.") if order.nil?

      amount = (@amount || order.total).round(2, half: :even)
      return failure("Сума оплати має бути більшою за нуль.") unless amount.positive?
      if amount > order.total
        return failure("Сума оплати не може перевищувати суму замовлення (#{format('%.2f',
                                                                                   order.total)}).")
      end

      currency = order.currency_code.to_s.strip.presence || "UAH"
      description = "Оплата замовлення ##{order.id}.\nПокупець: #{order.customer_name.strip}. \n" \
                    "Телефон: #{order.telephone.to_s.strip}"
      url = @client.checkout_url(order_id: order.id, amount:, currency:, description:)
      success(Link.new(url:, amount:, currency:, test: @client.test?))
    end
  end
end
