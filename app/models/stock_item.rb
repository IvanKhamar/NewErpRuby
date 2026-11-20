# A consumable (fabric, fittings, packaging): the old site's dd_stock_items (InnoDB, so row locks work).
# The quantity changes only through #adjust and #take_up_to, so every change gets a row in the movement log.
# Callers lock the row first (Stock::Adjust, Production::RecordOperation): see DECISIONS.md D7.
class StockItem < ApplicationRecord
  include BusinessText

  SCALE = 2 # dd_stock_items.stock is decimal(10,2)

  self.table_name = "dd_stock_items"
  self.primary_key = "item_id"

  belongs_to :category, class_name: "StockCategory", optional: true, inverse_of: :items
  belongs_to :supplier, class_name: "StockSupplier", optional: true, inverse_of: :items
  has_many :movements, -> { order(date_added: :desc, log_id: :desc) }, class_name: "StockLog",
                                                                       foreign_key: :item_id, inverse_of: :item,
                                                                       dependent: nil

  validates :name, presence: true, length: { maximum: 255 }
  validates :unit, presence: true, length: { maximum: 32 }
  validates :min_stock, :price, numericality: { greater_than_or_equal_to: 0 }

  # status = 0 is "deleted": the old module hides items instead of deleting them.
  scope :active, -> { where(status: true) }
  scope :in_category, ->(id) { where(category_id: id) }
  scope :below_minimum, -> { where("stock < min_stock") }
  scope :sorted, -> { order(:name) }

  def below_minimum? = stock < min_stock

  # Sets the description with the reference's messages. Never the quantity: that changes only through the log.
  def describe(category_id:, supplier_id:, name:, unit:, min_quantity:, used_for:, price:)
    raise DomainError, "Ціна не може бути від'ємною." if price.negative?
    raise DomainError, "Мінімальний залишок не може бути від'ємним." if min_quantity.negative?

    assign_attributes(category_id:, supplier_id:, name: require_text(name, "Назва позиції", 255),
                      unit: require_text(unit, "Одиниця виміру", 32), used_for: used_for.to_s.strip,
                      min_stock: min_quantity, price:)
    self
  end

  # A manual change by delta (+ receipt, − use). Stricter than the old module: never below zero.
  def adjust(delta, reason, user)
    raise DomainError, "Зміна залишку не може дорівнювати нулю." if delta.zero?
    raise DomainError, "Зміна залишку: не більше #{SCALE} знаків після коми." unless scale_ok?(delta, SCALE)
    if (stock + delta).negative?
      raise DomainError, "Недостатньо залишку: є #{plain(stock)} #{unit}, списується #{plain(-delta)} #{unit}."
    end

    record_change(delta, require_text(reason, "Причина", 255), user)
  end

  # Write-off for production, as in the old module: takes what there is, at most down to zero. The norm times
  # pieces can have more decimals than the column keeps, so it is rounded half up first, as MySQL does.
  def take_up_to(wanted, comment, user)
    raise DomainError, "Кількість для списання має бути більшою за нуль." unless wanted.positive?

    amount = [wanted.round(SCALE, half: :up), stock].min
    return nil unless amount.positive?

    record_change(-amount, require_text(comment, "Причина", 255), user)
  end

  private

  def record_change(delta, comment, user)
    before = stock
    self.stock = before + delta
    movements.build(item_name: name, user_id: user.id, username: user.username,
                    action: delta.positive? ? StockLog::RESTOCK : StockLog::USE, quantity: delta.abs,
                    stock_before: before, stock_after: stock, comment:, date_added: Time.current)
  end
end
