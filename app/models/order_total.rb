# The totals block of an order: sub_total, shipping, coupon (negative), total.
class OrderTotal < ApplicationRecord
  self.table_name = "dd_order_total"
  self.primary_key = "order_total_id"

  belongs_to :order, inverse_of: :totals
end
