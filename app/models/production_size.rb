# One size of a model with its cut and sewn stock. Every change builds a production log row, so the stock and
# the log never disagree. Callers lock the size rows before changing them.
class ProductionSize < ApplicationRecord
  include BusinessText

  SCALE = 3 # cut_stock and sewn_stock are decimal(12,3)
  CUT = "cut".freeze
  SEWN = "sewn".freeze

  self.table_name = "dd_stock_production_sizes"
  self.primary_key = "size_id"

  belongs_to :model, class_name: "ProductionModel", foreign_key: :production_id, inverse_of: :sizes
  has_many :log_entries, class_name: "ProductionLog", foreign_key: :size_id, inverse_of: :size, dependent: nil
  has_many :locations, class_name: "ProductionLocation", foreign_key: :size_id, inverse_of: :size, dependent: nil

  alias_attribute :name, :size_name

  # "+Покроєно": sets of this size were cut.
  def record_cut(quantity, comment, actor) = change(CUT, positive(quantity), comment, actor)

  # "В пошив": cut sets went to the seamstresses. Not more than was cut.
  def send_to_sewing(quantity, comment, actor)
    require_available(cut_stock, quantity, "розкроєно")
    change(CUT, -quantity, comment, actor)
  end

  # "+Пошито": ready pieces came to stock (for ready_made, a delivery from the supplier).
  def record_sewn(quantity, comment, actor) = change(SEWN, positive(quantity), comment, actor)

  # "Відвантажено": sewn pieces left not through an order. Not more than there is.
  def ship(quantity, comment, actor)
    require_available(sewn_stock, quantity, "пошито")
    change(SEWN, -quantity, comment, actor)
  end

  # An order takes sewn pieces. Like consumables it takes what there is: an empty stock never blocks an order.
  def take_for_order(wanted, order_id, actor)
    amount = [positive(wanted), sewn_stock].min.clamp(0..)
    return nil unless amount.positive?

    change(SEWN, -amount, ProductionLog.order_comment(order_id), actor)
  end

  # The order left the write-off statuses: its pieces come back.
  def return_from_order(quantity, order_id, actor)
    change(SEWN, positive(quantity), ProductionLog.cancel_comment(order_id), actor)
  end

  private

  def change(stage, delta, comment, actor)
    text = comment.to_s.strip
    raise DomainError, "Коментар: не довше 255 символів." if text.length > 255

    before = stage == CUT ? cut_stock : sewn_stock
    after = before + delta
    if stage == CUT
      self.cut_stock = after
    else
      self.sewn_stock = after
    end
    log_entries.build(production_id:, size_name:, stage:, direction: delta.positive? ? "in" : "out",
                      quantity: delta.abs, stock_before: before, stock_after: after, comment: text,
                      user_id: actor.id, username: actor.username, date_added: Time.current)
  end

  def positive(quantity)
    raise DomainError, "Кількість має бути більшою за нуль." unless quantity.positive?

    quantity
  end

  def require_available(available, quantity, what)
    positive(quantity)
    return if quantity <= available

    raise DomainError, "Розмір #{size_name}: #{what} лише #{plain(available)}, а вказано #{plain(quantity)}."
  end
end
