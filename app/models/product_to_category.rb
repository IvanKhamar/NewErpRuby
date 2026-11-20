class ProductToCategory < ApplicationRecord
  self.table_name = "dd_product_to_category"
  self.primary_key = %i[product_id category_id]
end
