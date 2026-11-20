# A product size with its storefront stock, pre-order limit and the date it is expected (PreOrderRow).
class PreOrderSerializer < ApplicationSerializer
  attributes :product_option_value_id, :product_id
  attribute(:product_name) { |v| v.product_name.to_s }
  attribute(:model) { |v| v.product_model.to_s }
  attribute(:size, &:value_name)
  attributes :quantity
  attribute(:quota, &:pre_order_quantity)
  attribute(:date_available) { |v| v.date_available&.iso8601 }
  attribute(:availability, &:availability)
end
