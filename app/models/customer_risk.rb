# How far a customer can be trusted, by their earlier orders (the old site's "Fraud Check").
# level is written as a number, like a .NET enum: 0 new, 1 green, 2 yellow, 3 red.
class CustomerRisk
  NEW = 0     # no orders of this customer yet
  GREEN = 1   # orders, none cancelled
  YELLOW = 2  # less than half cancelled
  RED = 3     # half or more cancelled: ask for prepayment

  attr_reader :level, :total_orders, :cancelled_order_ids, :suspicion_rate, :message

  # orders: [order id, status id] pairs.
  def self.of(orders, cancelled_status_id: ErpSettings.cancelled_status_id)
    return new(NEW, 0, [], BigDecimal(0), "Новий клієнт. Замовлень не знайдено.") if orders.empty?

    cancelled = orders.select { |_, status_id| status_id == cancelled_status_id }.map(&:first)
    rate = (BigDecimal(cancelled.size * 100) / orders.size).round(2, half: :even)
    if cancelled.empty?
      new(GREEN, orders.size, cancelled, rate, "Клієнт надійний. Скасувань немає.")
    elsif rate < 50
      new(YELLOW, orders.size, cancelled, rate, "Увага: є скасовані замовлення. Рекомендовано перевірити.")
    else
      new(RED, orders.size, cancelled, rate, "Потенційний фрод-ризик. Рекомендовано вимагати передоплату.")
    end
  end

  # Last 9 digits: "+38 (067) 123-45-67" and "0671234567" are one number.
  def self.phone_key(telephone)
    digits = telephone.to_s.gsub(/\D/, "")
    digits.length >= 9 ? digits[-9..] : nil
  end

  def initialize(level, total_orders, cancelled_order_ids, suspicion_rate, message)
    @level = level
    @total_orders = total_orders
    @cancelled_order_ids = cancelled_order_ids
    @suspicion_rate = suspicion_rate
    @message = message
  end
end
