# Sewn pieces of a size kept at another warehouse. The main warehouse has no row: it is the rest of sewn_stock.
class ProductionLocation < ApplicationRecord
  self.table_name = "erp_production_location"

  belongs_to :size, class_name: "ProductionSize", inverse_of: :locations
  belongs_to :warehouse
end
