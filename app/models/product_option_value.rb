# A value of a product option, usually a size. option_value_id points to the shared value ("M", "L"),
# which a production model size links to. pre_order_quantity is the pre-order limit of the size.
class ProductOptionValue < ApplicationRecord
  MAX_QUOTA = 9999

  # Whether the storefront can sell a size; written as a number, like a .NET enum.
  IN_STOCK = 0
  PRE_ORDER = 1 # no stock, but a pre-order limit: the storefront sells ahead
  SOLD_OUT = 2

  self.table_name = "dd_product_option_value"
  self.primary_key = "product_option_value_id"

  belongs_to :product, inverse_of: :option_values, optional: true # MyISAM: no foreign keys, a product may be gone
  has_one :option_description, -> { localized }, class_name: "OptionDescription", primary_key: :option_id,
                                                 foreign_key: :option_id, inverse_of: false, dependent: nil
  has_one :value_description, -> { localized }, class_name: "OptionValueDescription",
                                                primary_key: :option_value_id, foreign_key: :option_value_id,
                                                inverse_of: false, dependent: nil

  # Sizes sold ahead: negative stock while a limit is left.
  scope :sold_ahead, -> { where("quantity < 0 AND pre_order_quantity > 0") }

  # With the product name (in the lookup language) and model, for the pre-order list.
  scope :with_product_names, lambda {
    joins(:product)
      .joins(sanitize_sql_array(["INNER JOIN dd_product_description d ON d.product_id = dd_product.product_id " \
                                 "AND d.language_id = ?", ErpSettings.language_id]))
      .select("dd_product_option_value.*, d.name AS product_name, dd_product.model AS product_model")
  }

  def option_name = option_description&.name.to_s
  def value_name = value_description&.name.to_s

  # As in the old site's cart: a size without stock tracking is always in stock, pre-order when stock ≤ 0.
  def availability
    return IN_STOCK if !subtract || quantity.positive?

    pre_order_quantity.positive? ? PRE_ORDER : SOLD_OUT
  end

  # Takes what was sold ahead (negative stock) off the limit. The old code did limit += stock, and selling over the
  # limit gave a negative limit, which the storefront took as leave to sell further. Here the limit stops at 0 and
  # what was sold over it stays negative in the stock, so it can be seen. Returns [quantity, limit].
  def self.settled(quantity, quota)
    return [quantity, quota] if quantity >= 0 || quota <= 0

    covered = [quota, -quantity].min
    [quantity + covered, quota - covered]
  end
end
