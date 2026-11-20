# A single product (optionally one size) in a partner's feed, with its own name and prices.
class PartnerProductMap < ApplicationRecord
  self.table_name = "dd_partner_product_map"
  self.primary_key = "partner_product_map_id"

  belongs_to :partner, inverse_of: :product_maps
end
