# Who changed an order's status and when (the old site's own table, MyISAM).
class OrderStatusLog < ApplicationRecord
  self.table_name = "dd_order_status_log"
  self.primary_key = "order_status_log_id"

  belongs_to :order, inverse_of: :status_logs
  belongs_to :user, optional: true
  belongs_to :new_status, -> { localized }, class_name: "OrderStatus", foreign_key: :new_status_id,
                                            primary_key: :order_status_id, optional: true, inverse_of: false

  scope :chronological, -> { order(:date_added, :order_status_log_id) }
end
