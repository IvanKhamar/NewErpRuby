# A model linked through a catalog category: every product of the category whose name contains name_filter
# (or equals it when match_exact). An empty filter takes the whole category.
class ProductionCategory < ApplicationRecord
  self.table_name = "dd_stock_production_categories"
  self.primary_key = %i[production_id oc_category_id]

  belongs_to :model, class_name: "ProductionModel", foreign_key: :production_id, inverse_of: :category_links

  def matches?(product_name)
    return true if name_filter.blank?

    match_exact ? product_name.casecmp?(name_filter) : product_name.downcase.include?(name_filter.downcase)
  end
end
