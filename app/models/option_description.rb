class OptionDescription < ApplicationRecord
  self.table_name = "dd_option_description"
  self.primary_key = %i[option_id language_id]

  scope :localized, -> { where(language_id: ErpSettings.language_id) }
end
