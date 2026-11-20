# The chosen option (size) of an order line.
class OrderOption < ApplicationRecord
  self.table_name = "dd_order_option"
  self.primary_key = "order_option_id"
  self.inheritance_column = nil # "type" is the option kind (radio, select), not single-table inheritance

  belongs_to :order, inverse_of: :options
  belongs_to :order_product, inverse_of: :options
  belongs_to :product_option_value, optional: true
end
