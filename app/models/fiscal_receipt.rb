# A sale receipt for Checkbox, built from an order as the old site did: products with a price, one payment for the
# sum to pay, and a discount for the difference if the products cost more (a coupon, the advance). Money in kopecks.
class FiscalReceipt
  CASHLESS_PAYMENT_CODES = %w[wayforpay liqpay mono bank_transfer paid paid_shipping cod].freeze
  CASH_ON_DELIVERY_CODE = "cod".freeze

  Good = Data.define(:code, :name, :price, :quantity) # quantity in thousandths, as Checkbox wants

  attr_reader :goods, :payment_type, :payment_label, :to_pay, :discount, :footer, :email, :cashier_name

  def self.build(order:, cashier_name:, total:)
    goods = order.products.reject { |line| line.price.zero? }
                 .map do |line|
      Good.new(code: line.product_id.to_s, name: line.name.strip, price: kopecks(line.price),
               quantity: line.quantity * 1000)
    end
    raise DomainError, "У замовленні немає товарів з ціною, чек видати нема з чого." if goods.empty?

    to_pay = kopecks(total)
    raise DomainError, "Сума до оплати нульова, чек не потрібен." unless to_pay.positive?

    goods_total = goods.sum { |g| g.price * g.quantity / 1000 }
    if to_pay > goods_total
      raise DomainError, "Сума до оплати (#{format('%.2f', total)}) більша за суму товарів " \
                         "(#{format('%.2f', goods_total / 100.0)}): мабуть, у замовленні є платна доставка. " \
                         "Checkbox такий чек не прийме."
    end
    new(goods:, order:, cashier_name:, to_pay:, discount: goods_total - to_pay)
  end

  def self.kopecks(value) = (value * 100).round(half: :up).to_i

  def initialize(goods:, order:, cashier_name:, to_pay:, discount:)
    @goods = goods
    @cashier_name = cashier_name
    @to_pay = to_pay
    @discount = discount
    @payment_type = CASHLESS_PAYMENT_CODES.include?(order.payment_code) ? "CASHLESS" : "CASH"
    @payment_label = payment_label_for(order)
    @footer = "Замовлення № #{order.id}"
    @email = order.email.to_s.strip.presence
  end

  # The body of POST /api/v1/receipts/sell.
  def to_checkbox
    body = { cashier_name:, footer:,
             goods: goods.map { |g| { good: { code: g.code, name: g.name, price: g.price }, quantity: g.quantity } },
             payments: [{ type: payment_type, value: to_pay, label: payment_label }] }
    body[:discounts] = [{ type: "DISCOUNT", mode: "VALUE", value: discount }] if discount.positive?
    body[:delivery] = { email: } if email
    body
  end

  private

  # An OpenCart payment method name may hold HTML (icons, &quot;): only the text goes to the receipt.
  def payment_label_for(order)
    return "Оплата в Nova pay" if order.payment_code == CASH_ON_DELIVERY_CODE

    text = Rails::HTML5::FullSanitizer.new.sanitize(CGI.unescapeHTML(order.payment_method.to_s)).squish
    text.presence || (payment_type == "CASH" ? "Готівка" : "Безготівкова оплата")
  end
end
