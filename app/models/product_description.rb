class ProductDescription < ApplicationRecord
  self.table_name = "dd_product_description"
  self.primary_key = %i[product_id language_id]

  scope :localized, -> { where(language_id: ErpSettings.language_id) }
end
