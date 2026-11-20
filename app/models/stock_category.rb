class StockCategory < ApplicationRecord
  self.table_name = "dd_stock_categories"
  self.primary_key = "category_id"

  has_many :items, class_name: "StockItem", foreign_key: :category_id, inverse_of: :category, dependent: nil

  validates :name, presence: true, length: { maximum: 128 }

  scope :sorted, -> { order(:sort_order, :name) }
end
