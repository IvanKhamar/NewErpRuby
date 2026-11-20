# Production log (dd_stock_production_log): every change of a size's cut or sewn stock.
# Order write-offs are found by their comment, as the old site writes them ("Замовлення #42", "Скасування #42").
class ProductionLog < ApplicationRecord
  self.table_name = "dd_stock_production_log"
  self.primary_key = "log_id"

  belongs_to :size, class_name: "ProductionSize", inverse_of: :log_entries

  def self.order_comment(order_id) = "Замовлення ##{order_id}"
  def self.cancel_comment(order_id) = "Скасування ##{order_id}"

  # Sewn pieces an order holds now, by size id: taken by the order minus returned on its cancel.
  def self.sewn_held_by_order(order_id)
    rows = where(stage: ProductionSize::SEWN, comment: [order_comment(order_id), cancel_comment(order_id)])
           .pluck(:size_id, :direction, :comment, :quantity)
    rows.each_with_object(Hash.new(0)) do |(size_id, direction, comment, quantity), held|
      if comment == order_comment(order_id) && direction == "out"
        held[size_id] += quantity
      elsif comment == cancel_comment(order_id) && direction == "in"
        held[size_id] -= quantity
      end
    end
  end
end
