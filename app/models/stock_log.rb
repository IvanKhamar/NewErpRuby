# The movement log of consumables (dd_stock_log). quantity is always positive; action tells the direction.
class StockLog < ApplicationRecord
  USE = "use".freeze
  RESTOCK = "restock".freeze

  self.table_name = "dd_stock_log"
  self.primary_key = "log_id"

  belongs_to :item, class_name: "StockItem", inverse_of: :movements

  def delta = action == USE ? -quantity : quantity
end
