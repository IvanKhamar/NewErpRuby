# Where an order came from (site, Instagram, phone call...). Multilingual like the statuses.
class OrderSource < ApplicationRecord
  self.table_name = "dd_order_source"
  self.primary_key = %i[order_source_id language_id]

  scope :localized, -> { where(language_id: ErpSettings.language_id) }
end
