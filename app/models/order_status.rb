# Order status lookup (multilingual, like every OpenCart lookup); the composite key is (order_status_id, language_id).
class OrderStatus < ApplicationRecord
  self.table_name = "dd_order_status"
  self.primary_key = %i[order_status_id language_id]

  scope :localized, -> { where(language_id: ErpSettings.language_id) }

  def self.exists_with_id?(id) = localized.exists?(order_status_id: id)
end
