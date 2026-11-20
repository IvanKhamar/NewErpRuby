# A category (optionally only one size of it) in a partner's feed, with markups in percent.
class PartnerCategoryMap < ApplicationRecord
  self.table_name = "dd_partner_category_map"
  self.primary_key = "partner_category_map_id"

  belongs_to :partner, inverse_of: :category_maps
end
