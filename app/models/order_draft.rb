# An order a manager makes by hand (phone call, social networks). Checks what the old site's quick order form
# checked and counts the totals: products + shipping − discount. A plain Ruby object: it has no table.
class OrderDraft
  Line = Data.define(:product_id, :product_option_value_id, :quantity, :price) do
    def total = price * quantity
  end

  attr_reader :lines, :shipping_cost, :discount, :prepayment

  def initialize(lines:, shipping_cost:, discount:, prepayment:)
    @lines = lines
    @shipping_cost = shipping_cost
    @discount = discount
    @prepayment = prepayment
  end

  def sub_total = lines.sum(BigDecimal(0), &:total)
  def total = sub_total + shipping_cost - discount

  # The customer and the methods (a new order); raises DomainError with the first broken rule.
  def validate_customer!(firstname:, telephone:, shipping_method:, payment_method:)
    raise DomainError, "Вкажіть ім'я або телефон клієнта." if firstname.to_s.strip.empty? && telephone.to_s.strip.empty?
    raise DomainError, "Необхідний спосіб доставки." if shipping_method.to_s.strip.empty?
    raise DomainError, "Необхідний спосіб оплати." if payment_method.to_s.strip.empty?

    validate_lines!
  end

  def validate_lines!
    raise DomainError, "Кошик не може бути порожнім." if lines.empty?
    raise DomainError, "Кількість товару має бути більшою за нуль." if lines.any? { |l| l.quantity <= 0 }
    raise DomainError, "Ціна товару не може бути від'ємною." if lines.any? { |l| l.price.negative? }
    if [shipping_cost, discount, prepayment].any?(&:negative?)
      raise DomainError, "Доставка, знижка й завдаток не можуть бути від'ємними."
    end
    raise DomainError, "Знижка не може перевищувати суму замовлення." if total.negative?
    raise DomainError, "Сума завдатку не може перевищувати суму замовлення." if prepayment > total

    self
  end
end
