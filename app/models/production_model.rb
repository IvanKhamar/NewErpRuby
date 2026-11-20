# A garment model the workshop cuts and sews (the old site's StockTrack module, dd_stock_production).
# type: "clothing" (own sewing: cut → sewn) or "ready_made" (ready goods from a supplier, only sewn stock).
class ProductionModel < ApplicationRecord
  CLOTHING = "clothing".freeze
  READY_MADE = "ready_made".freeze
  TYPES = [CLOTHING, READY_MADE].freeze

  self.table_name = "dd_stock_production"
  self.primary_key = "production_id"
  self.inheritance_column = nil # the "type" column is a business value, not Rails single-table inheritance

  has_many :sizes, -> { order(:sort_order, :size_id) }, class_name: "ProductionSize", foreign_key: :production_id,
                                                        inverse_of: :model, dependent: nil
  has_many :components, -> { order(:sort_order, :component_id) }, class_name: "ProductionComponent",
                                                                  foreign_key: :production_id, inverse_of: :model,
                                                                  dependent: nil
  has_many :sewn_bom_lines, class_name: "SewnBomLine", foreign_key: :production_id, inverse_of: :model,
                            dependent: nil
  has_many :product_links, class_name: "ProductionProduct", foreign_key: :production_id, inverse_of: :model,
                           dependent: nil
  has_many :category_links, class_name: "ProductionCategory", foreign_key: :production_id, inverse_of: :model,
                            dependent: nil

  validates :name, presence: true, length: { maximum: 150 }
  validates :type, inclusion: { in: TYPES }
  validates :min_total, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(status: true) }
  scope :of_type, ->(type) { where(type:) }
  scope :sorted, -> { order(:sort_order, :name) }

  def require_size(size_id)
    sizes.find { |size| size.id == size_id } ||
      raise(DomainError, "Розмір #{size_id} не належить моделі \"#{name}\".")
  end

  def total_cut = sizes.sum(&:cut_stock)
  def total_sewn = sizes.sum(&:sewn_stock)
end
