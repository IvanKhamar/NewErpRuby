class OrderProduct < ApplicationRecord
  self.table_name = "dd_order_product"
  self.primary_key = "order_product_id"

  belongs_to :order, inverse_of: :products
  has_many :options, class_name: "OrderOption", inverse_of: :order_product,
                     dependent: nil
end
