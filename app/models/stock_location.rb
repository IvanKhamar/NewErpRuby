# A consumable kept at another warehouse. The main warehouse has no row: it is the rest of dd_stock_items.stock.
class StockLocation < ApplicationRecord
  self.table_name = "erp_stock_location"

  belongs_to :item, class_name: "StockItem"
  belongs_to :warehouse
end
