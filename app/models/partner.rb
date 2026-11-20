# A reseller partner (dd_partner) and how its XML feed maps our categories and products to theirs.
class Partner < ApplicationRecord
  self.table_name = "dd_partner"
  self.primary_key = "partner_id"

  has_many :category_maps, -> { order(:partner_category_map_id) }, class_name: "PartnerCategoryMap",
                                                                   inverse_of: :partner, dependent: nil
  has_many :product_maps, -> { order(:partner_product_map_id) }, class_name: "PartnerProductMap",
                                                                 inverse_of: :partner, dependent: nil
end
