# Sewing BOM row: one sewn piece takes cut parts (component_id) and direct consumables (item_id: threads, labels).
class SewnBomLine < ApplicationRecord
  self.table_name = "dd_stock_production_sewn_bom"
  self.primary_key = "bom_id"

  belongs_to :model, class_name: "ProductionModel", foreign_key: :production_id, inverse_of: :sewn_bom_lines
  belongs_to :component, class_name: "ProductionComponent", optional: true
  belongs_to :item, class_name: "StockItem", optional: true

  validates :qty_per_unit, numericality: { greater_than: 0 }
end
