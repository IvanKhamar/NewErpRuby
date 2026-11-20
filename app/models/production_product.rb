# A catalog product linked to a model directly: order lines of this product take the model's sewn pieces.
class ProductionProduct < ApplicationRecord
  self.table_name = "dd_stock_production_products"
  self.primary_key = %i[production_id product_id]

  belongs_to :model, class_name: "ProductionModel", foreign_key: :production_id, inverse_of: :product_links
end
