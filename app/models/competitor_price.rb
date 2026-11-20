# Price history of a competitor page: a row appears when the price changed.
class CompetitorPrice < ApplicationRecord
  self.table_name = "erp_competitor_price"

  belongs_to :link, class_name: "CompetitorLink", inverse_of: :prices
end
