# The manager responsible for an order (NewErp's own table).
class OrderManager < ApplicationRecord
  self.table_name = "erp_order_manager"
  self.primary_key = "order_id"

  belongs_to :order, inverse_of: :manager_assignment
  belongs_to :user
end
