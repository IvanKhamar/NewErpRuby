class StockSupplier < ApplicationRecord
  self.table_name = "dd_stock_suppliers"
  self.primary_key = "supplier_id"

  has_many :items, class_name: "StockItem", foreign_key: :supplier_id, inverse_of: :supplier, dependent: nil
end
