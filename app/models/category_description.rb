class CategoryDescription < ApplicationRecord
  self.table_name = "dd_category_description"
  self.primary_key = %i[category_id language_id]

  scope :localized, -> { where(language_id: ErpSettings.language_id) }
end
