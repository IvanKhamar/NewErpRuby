# A value of a product option, usually a size. option_value_id points to the shared value ("M", "L"),
# which a production model size links to.
class ProductOptionValue < ApplicationRecord
  self.table_name = "dd_product_option_value"
  self.primary_key = "product_option_value_id"

  belongs_to :product, inverse_of: :option_values, optional: true # MyISAM: no foreign keys, a product may be gone
  has_one :option_description, -> { localized }, class_name: "OptionDescription", primary_key: :option_id,
                                                 foreign_key: :option_id, inverse_of: false, dependent: nil
  has_one :value_description, -> { localized }, class_name: "OptionValueDescription",
                                                primary_key: :option_value_id, foreign_key: :option_value_id,
                                                inverse_of: false, dependent: nil

  def option_name = option_description&.name.to_s
  def value_name = value_description&.name.to_s
end
