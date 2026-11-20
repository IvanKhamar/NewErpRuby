# A catalog product of the shop (OpenCart). NewErp reads it for new orders and production links.
class Product < ApplicationRecord
  self.table_name = "dd_product"
  self.primary_key = "product_id"

  has_one :description, -> { localized }, class_name: "ProductDescription", foreign_key: :product_id,
                                          inverse_of: false, dependent: nil
  has_many :option_values, class_name: "ProductOptionValue", inverse_of: :product,
                           dependent: nil
  has_many :category_links, class_name: "ProductToCategory", inverse_of: false,
                            dependent: nil

  def name = description&.name.to_s
end
