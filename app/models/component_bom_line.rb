# Cutting BOM row: qty_per_unit of a consumable for one part. size_id NULL means every size; a row for a size
# overrides the general row for that size (see Production::Bom).
class ComponentBomLine < ApplicationRecord
  self.table_name = "dd_stock_production_component_bom"
  self.primary_key = "bom_id"

  belongs_to :component, class_name: "ProductionComponent", inverse_of: :bom_lines
  belongs_to :item, class_name: "StockItem", optional: true

  validates :qty_per_unit, numericality: { greater_than: 0 }
end
