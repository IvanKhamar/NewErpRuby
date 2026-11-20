# A cut part of a model (front, back, sleeve) with its cutting BOM: consumables one part takes.
class ProductionComponent < ApplicationRecord
  self.table_name = "dd_stock_production_components"
  self.primary_key = "component_id"

  belongs_to :model, class_name: "ProductionModel", foreign_key: :production_id, inverse_of: :components
  has_many :bom_lines, class_name: "ComponentBomLine", foreign_key: :component_id, inverse_of: :component,
                       dependent: nil
  has_many :stocks, class_name: "ComponentStock", foreign_key: :component_id, inverse_of: :component, dependent: nil

  validates :name, presence: true, length: { maximum: 100 }
end
